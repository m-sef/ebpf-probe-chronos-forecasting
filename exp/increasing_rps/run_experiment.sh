#!/usr/bin/env bash

echo "WARM UP - 1500/s for 60s"
echo "GET http://10.10.1.1:8080/burn?burn=20"| vegeta attack -rate="1500/s" -duration="60s" -keepalive=false | vegeta encode -to=csv -output=/tmp/vegeta.log

for (( i = 1600; i <= 2000; i += 100 )); do
    echo "RAMP UP - ${i}/s for 30s"
    echo "GET http://10.10.1.1:8080/burn?burn=20"| vegeta attack -rate="${i}/s" -duration="30s" -keepalive=false | vegeta encode -to=csv -output=/tmp/vegeta.log
done

echo "WARM UP - 1500/s for 60s"
echo "GET http://10.10.1.1:8080/burn?burn=20"| vegeta attack -rate="1500/s" -duration="60s" -keepalive=false | vegeta encode -to=csv -output=/tmp/vegeta.log

for (( i = 1600; i <= 2000; i += 100 )); do
    echo "RAMP UP - ${i}/s for 30s"
    echo "GET http://10.10.1.1:8080/burn?burn=20"| vegeta attack -rate="${i}/s" -duration="30s" -keepalive=false | vegeta encode -to=csv -output=/tmp/vegeta.log
done

exit 0