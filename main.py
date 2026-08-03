#!/usr/bin/env python3
import threading
import signal
import time
from pathlib import Path
import argparse

import pandas
from chronos import Chronos2Pipeline

EBPF_PROBE_DIR   = "/sys/fs/bpf/ebpf_probe/"
FORECAST_LOG_DIR = "/tmp/ebpf-probe-chronos-forecasting/"

SUMMARY_COLUMNS = ['core', 'event', 'value', 'enabled_ns', 'running_ns']

DEFAULT_CONTEXT_LENGTH      = 30
DEFAULT_PREDICTION_LENGTH   = 10
DEFAULT_SAMPLE_INTERVAL     = 10
DEFAULT_PREDICTION_INTERVAL = 10

def sample() -> pandas.DataFrame:
    # ead each iterator file and coalesce into a single sample DataFrame
    summary_data_frames : list[pandas.DataFrame] = []
    
    for subpath in Path(EBPF_PROBE_DIR).iterdir():
        if "rapl" in subpath.name:
            continue
    
        summary_path = subpath / "summary"
        if (summary_path.exists()):
            summary_data_frame = pandas.read_csv(summary_path, header=None, names=SUMMARY_COLUMNS, na_values="N/A")
            summary_data_frames.append(summary_data_frame)
    
    sample_data_frame = pandas.concat(summary_data_frames)
    sample_data_frame.insert(0, "timestamp_s", int(time.time()))
    sample_data_frame['timestamp_s'] = pandas.to_datetime(sample_data_frame['timestamp_s'], unit='s')
    sample_data_frame = sample_data_frame.set_index('timestamp_s').fillna(1.0)
    
    #print(sample_data_frame)
    
    # Transform the sample DataFrame to be usable with Chronos
    sample_data_frame = sample_data_frame.pivot_table(
        index=sample_data_frame.index,
        columns=['core', 'event'],
        values=['value', 'enabled_ns', 'running_ns'],
    )
    sample_data_frame = sample_data_frame['value'] * sample_data_frame['enabled_ns'] / sample_data_frame['running_ns']
    sample_data_frame = sample_data_frame.T.groupby(level='event').sum().T.sort_index(axis=1)
    
    #print(sample_data_frame)

    return sample_data_frame

def sample_callback(
        stop_signal        : threading.Event,
        mutex_lock         : threading.Lock,
        context_data_frame : pandas.DataFrame,
        initial_data_frame : pandas.DataFrame,
        sample_interval    : float,
        context_length     : int) -> None:

    previous_data_frame = initial_data_frame
    start_timestamp     = pandas.Timestamp.now()
    sample_index        = 0

    while not stop_signal.is_set():
        sample_data_frame = sample()
        diffed_data_frame = sample_data_frame - previous_data_frame.values
        previous_data_frame = sample_data_frame

        sample_index += 1

        diffed_data_frame.insert(0, 'timestamp_s', start_timestamp + pandas.Timedelta(seconds=sample_interval * sample_index))
        diffed_data_frame['item_id'] = 'ebpf'

        with mutex_lock:
            combined_data_frame = pandas.concat([context_data_frame, diffed_data_frame]).tail(context_length)

            context_data_frame.drop(index=context_data_frame.index, columns=context_data_frame.columns, inplace=True)
            for column in combined_data_frame.columns:
                context_data_frame[column] = combined_data_frame[column]

        #print(context_data_frame)

        time.sleep(sample_interval)

def prediction_callback(
        stop_signal         : threading.Event,
        mutex_lock          : threading.Lock,
        pipeline            : Chronos2Pipeline,
        context_data_frame  : pandas.DataFrame,
        prediction_interval : float,
        context_length      : int,
        prediction_length   : int,
        context_path        : str | None,
        prediction_path     : str | None) -> None:
    
    while not stop_signal.is_set():
        if len(context_data_frame) == context_length:
            print("ENOUGH DATA TO MAKE PREDICTION")

            with mutex_lock:
                prediction_data_frame = pipeline.predict_df(
                    context_data_frame,
                    id_column="item_id",
                    timestamp_column="timestamp_s",
                    target="rx_bytes",
                    prediction_length=prediction_length,
                )

                if (context_path):
                    context_data_frame.to_csv(context_path, mode='a', header=False, index=False)

                if (prediction_path):
                    prediction_data_frame.to_csv(prediction_path, mode='a', header=False, index=False)
        else:
            print("NOT ENOUGH DATA TO MAKE PREDICTION")

        time.sleep(prediction_interval)

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-s", "--sample-interval", type=float, default=DEFAULT_SAMPLE_INTERVAL,
        help="Time (in seconds) between each sample")
    parser.add_argument(
        "-c", "--context-length", type=int, default=DEFAULT_CONTEXT_LENGTH,
        help="Length of context window (samples)")
    parser.add_argument(
        "--context-path", type=str,
        help="File path to write context data to")

    parser.add_argument(
        "-f", "--prediction-interval", type=float, default=DEFAULT_PREDICTION_INTERVAL,
         help="Time (in seconds) between each prediction")
    parser.add_argument(
        "-p", "--prediction-length", type=int, default=DEFAULT_PREDICTION_LENGTH,
        help="Length of prediction DataFrame (samples)")
    parser.add_argument(
        "--prediction-path", type=str,
        help="File path to write prediction data to")
    
    return parser.parse_args()

def main() -> None:
    args = parse_args()

    pipeline : Chronos2Pipeline = Chronos2Pipeline.from_pretrained("amazon/chronos-2")

    stop_signal = threading.Event()
    mutex_lock  = threading.Lock()

    context_data_frame = pandas.DataFrame()
    initial_data_frame = sample()

    sample_thread = threading.Thread(
        target=sample_callback,
        args=(
            stop_signal, mutex_lock,
            context_data_frame, initial_data_frame,
            args.sample_interval, args.context_length),
        daemon=True)
    sample_thread.start()

    prediction_thread = threading.Thread(
        target=prediction_callback,
        args=(
            stop_signal, mutex_lock,
            pipeline, context_data_frame,
            args.prediction_interval, args.context_length, args.prediction_length,
            args.context_path, args.prediction_path),
        daemon=True)
    prediction_thread.start()

    try:
        while True:
            signal.pause()
    except KeyboardInterrupt:
        stop_signal.set()
        print("")

if __name__ == '__main__':
    main()