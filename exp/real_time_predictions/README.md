# ebpf-probe-chronos-forecasting/exp/real_time_predictions

Using Chronos to make latency predictions on eBPF Probe data that has already been gathered.

## Notes

| Node | IP | OS | Node Type | Description
| :- | :- | :- | :- | :- |
| master | 10.1.1.2 | Ubuntu 24.04 | CloudLab c220g2 | Vegeta Workload Generator |
| worker0 | 10.1.1.2 | Ubuntu 24.04 | CloudLab c220g2 | Webserver |

__Hyperthreading and Turbo Boost is disabled on all nodes__

__irqbalance is intentionally disabled on the node running the webserver__

__CPU Governer is set "performance" on all nodes__

## Vegeta Setup

Setting up Vegeta on the master node:

```bash
# Assuming setup under the /local/ directory
cd /local/

# Clone and make Vegeta
git clone https://github.com/tsenart/vegeta.git

cd vegeta/

sudo apt-get update -y
sudo apt-get install -y golang golang-easyjson
make vegeta

# Move Vegeta under /usr/bin so it can be called without using file path
sudo mv vegeta /usr/bin
```

## Axum Webserver Setup

Setting up the Axum Webserver on the worker node:

```bash
# Assuming setup under the /local/ directory
cd /local/

git clone https://github.com/m-sef/axum-webserver.git

cd axum-webserver/

# If rust is not already set up
sudo apt-get update -y
sudo apt-get install -y rustup
rustup default stable

# Compiling the webserver
cargo build --release
```

## eBPF Probe Setup

Setting up eBPF Probe on the worker node:

```bash
# Assuming setup under the /local/ directory
cd /local/

git clone https://github.com/m-sef/ebpf-probe-cpp.git

cd ebpf-probe-cpp/

# Installing dependencies
sudo apt-get update -y
sudo apt-get install -y libbpf-dev cmake clang

# Compiling eBPF Probe
mkdir build
cd build/
cmake ..
make -j
```

## eBPF Probe Shepherd MustHerd Setup

Setting up the Shepherd on the master node:

```bash
# Assuming setup under the /local/ directory
cd /local/

git clone https://github.com/m-sef/ebpf-probe-shepherd-muster.git
```

Setting up the Muster on the worker node:

```bash
# Assuming setup under the /local/ directory
cd /local/

git clone https://github.com/m-sef/ebpf-probe-shepherd-muster.git
```

## Running the Experiment

First, on the worker node run the following processes

```bash
# Running the Axum Webserver
cd /local/axum-webserver/
sudo ./target/release/crust -i $(nproc)

# Running eBPF Probe
cd /local/ebpf-probe/build
sudo ./ebpf_probe -i ${WORKER_IF}

# Running the Muster
cd /local/ebpf-probe-shepherd-muster/shep_remote_muster/
sudo go run ebpf_probe_muster/*
```

Then, on the master node run the Shepherd to begin moving eBPF Probe data to the master node

```bash
# Running the Shepherd
cd /local/ebpf-probe-shepherd-muster/shep_remote_muster/
sudo go run shepherd/*
```

Next, run the Vegeta workload via `run_experiment.sh`

Afterwards, try to immediately run the Chronos forecaster

```bash
sudo .venv/bin/python3 main.py --sample-interval=6.0 --prediction-interval=6.0 --context-length=70 --prediction-length=10 --context-path=/tmp/context.log --prediction-path=/tmp/prediction.log
```

After `run_experiment.sh` is finished, terminate the Chronos forecaster, and move the log files to `results/` to then graph using `graph.ipynb`