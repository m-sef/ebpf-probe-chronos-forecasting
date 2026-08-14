#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

MASTER=slmoore@c220g2-011125.wisc.cloudlab.us

scp $MASTER:/tmp/context.log $SCRIPT_DIR/results/
scp $MASTER:/tmp/prediction.log $SCRIPT_DIR/results/
scp $MASTER:/tmp/rps_changes.log $SCRIPT_DIR/results/
scp $MASTER:/tmp/vegeta.log $SCRIPT_DIR/results

exit 0