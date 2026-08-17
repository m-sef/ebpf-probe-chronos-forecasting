# eBPF Probe Chronos Forecasting

Python program to make real time P99 latency predictions using eBPF Probe and Vegeta data with Chronos.

## Setup

```bash
python -m venv .venv
source .venv/bin/activate

pip install pandas chronos-forecasting

sudo .venv/bin/python3 main.py
```

## Usage

| Option | Long Option | Description |
|--------|-------------|-------------|
| `-h` | `--help` | Show help |
| `-s` | `--sample-interval` | Time (in seconds) between each sample |
| `-c` | `--context-length` | Length of context window (samples) |
| | `--context-path` | File path to write context data to |
| `-f` | `--prediction-interval` | Time (in seconds) between each prediction |
| `-p` | `--prediction-length` | Length of prediction DataFrame (samples) |
|  | `--prediction-path` | File path to write prediction data to |

## Experiments

See [predictions](exp/predictions/) for predicting P99 latency after collecting eBPF Data

See [real_time_predictions](exp/real_time_predictions/) for using [main.py](main.py) to make real-time P99 latency predictions
