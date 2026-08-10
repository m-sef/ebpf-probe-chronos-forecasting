#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

MASTER=slmoore@c220g2-011116.wisc.cloudlab.us

scp $MASTER:/local/ebpf-probe-chronos-forecasting/context.log $SCRIPT_DIR/results/
scp $MASTER:/local/ebpf-probe-chronos-forecasting/prediction.log $SCRIPT_DIR/results/

exit 0