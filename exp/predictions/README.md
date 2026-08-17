# ebpf-probe-chronos-forecasting/exp/predictions

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

## Running the experiment

First, on the worker node run the Axum Webserver and eBPF Probe

```bash
# Run the axum webserver using all cores (Reccomended to run in a seperate pane or run in the background using &)
cd /local/axum-webserver/
sudo ./target/release/crust -t $(nproc)

# Run eBPF Probe (Also reccomended to run in a seperate pane or run in the background using &)
# ${WORKER_IF} should be replaced with the name of the interface that worker0 uses to communicate with master
cd /local/ebpf-probe-cpp/build/
sudo ./ebpf_probe -i ${WORKER_IF}

# Collect log data
# Adjust ${SAMPLE_INTERVAL} to control granularity of data
cd /local/ebpf-probe-cpp/scripts/
sudo .venv/bin/python3 gather_data.py -i ${SAMPLE_INTERVAL}
```

Then, either manually run Vegeta on the master node, or run `run_experiment.sh`. After you are done running your workload, terminate `gather_data.py` on worker0 and move the data under `results/`