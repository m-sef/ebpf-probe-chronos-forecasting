#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

VEGETA=slmoore@c220g2-011110.wisc.cloudlab.us
WEBSERVER=slmoore@c220g2-011105.wisc.cloudlab.us

scp $VEGETA:/tmp/vegeta.log $SCRIPT_DIR/results/
scp $WEBSERVER:/tmp/summary.log $SCRIPT_DIR/results/

exit 0