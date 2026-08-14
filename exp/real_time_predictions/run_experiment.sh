#!/usr/bin/env bash

RPS_LOG=/tmp/rps_changes.log
RPS_LOWER_BOUND=1500
RPS_UPPER_BOUND=2500

log_rps_change() {
    date '+%Y-%m-%d %H:%M:%S.%6N' >> "$RPS_LOG"
}

log_rps_change
echo "WARM UP - ${RPS_LOWER_BOUND}/s for 60s"
echo "GET http://10.10.1.1:8080/burn?burn=20"| vegeta attack -rate="${RPS_LOWER_BOUND}/s" -duration="60s" -keepalive=false | vegeta encode -to=csv -output=/tmp/vegeta.log

for (( i = RPS_LOWER_BOUND + 100; i <= RPS_UPPER_BOUND; i += 100 )); do
    log_rps_change
    echo "RAMP UP - ${i}/s for 30s"
    echo "GET http://10.10.1.1:8080/burn?burn=20"| vegeta attack -rate="${i}/s" -duration="30s" -keepalive=false | vegeta encode -to=csv -output=/tmp/vegeta.log
done

for (( i = RPS_UPPER_BOUND - 100; i >= RPS_LOWER_BOUND + 100; i -= 100 )); do
    log_rps_change
    echo "RAMP DOWN - ${i}/s for 30s"
    echo "GET http://10.10.1.1:8080/burn?burn=20"| vegeta attack -rate="${i}/s" -duration="30s" -keepalive=false | vegeta encode -to=csv -output=/tmp/vegeta.log
done

log_rps_change
echo "WARM UP - ${RPS_LOWER_BOUND}/s for 60s"
echo "GET http://10.10.1.1:8080/burn?burn=20"| vegeta attack -rate="${RPS_LOWER_BOUND}/s" -duration="60s" -keepalive=false | vegeta encode -to=csv -output=/tmp/vegeta.log

for (( i = RPS_LOWER_BOUND + 100; i <= RPS_UPPER_BOUND; i += 100 )); do
    log_rps_change
    echo "RAMP UP - ${i}/s for 30s"
    echo "GET http://10.10.1.1:8080/burn?burn=20"| vegeta attack -rate="${i}/s" -duration="30s" -keepalive=false | vegeta encode -to=csv -output=/tmp/vegeta.log
done

for (( i = RPS_UPPER_BOUND - 100; i >= RPS_LOWER_BOUND + 100; i -= 100 )); do
    log_rps_change
    echo "RAMP DOWN - ${i}/s for 30s"
    echo "GET http://10.10.1.1:8080/burn?burn=20"| vegeta attack -rate="${i}/s" -duration="30s" -keepalive=false | vegeta encode -to=csv -output=/tmp/vegeta.log
done

exit 0
