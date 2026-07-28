# ebpf-probe-chronos-forecasting/exp/webserver

Using Chronos to make latency predictions using eBPF Probe data

## Notes

| Node | IP | OS | Node Type | Description
| :- | :- | :- | :- | :- |
| master | ? | Ubuntu 24.04 | CloudLab c220g2 | Vegeta Workload Generator |
| worker0 | ? | Ubuntu 24.04 | CloudLab c220g2 | Webserver |

__Hyperthreading and Turbo Boost is disabled on all nodes__

__irqbalance is intentionally disabled on the node running the webserver__

__CPU Governer is set "performance" on all nodes__