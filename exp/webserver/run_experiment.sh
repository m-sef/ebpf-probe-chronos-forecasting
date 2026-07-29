#!/usr/bin/env bash

for (( i = 1000; i <= 2500; i += 100 )); do
    echo "${i}/s"
    echo "GET http://10.10.1.1:8080/burn?burn=20" | vegeta attack -rate="${i}/s" -duration="15s" -keepalive=false | vegeta encode -to=csv -output="/tmp/1vegeta${i}.log"
done

for (( i = 2400; i >= 1000; i -= 100 )); do
    echo "${i}/s"
    echo "GET http://10.10.1.1:8080/burn?burn=20" | vegeta attack -rate="${i}/s" -duration="15s" -keepalive=false | vegeta encode -to=csv -output="/tmp/2vegeta${i}.log"
done

for (( i = 1100; i <= 2500; i += 100 )); do
    echo "${i}/s"
    echo "GET http://10.10.1.1:8080/burn?burn=20" | vegeta attack -rate="${i}/s" -duration="15s" -keepalive=false | vegeta encode -to=csv -output="/tmp/3vegeta${i}.log"
done

for (( i = 2400; i >= 1000; i -= 100 )); do
    echo "${i}/s"
    echo "GET http://10.10.1.1:8080/burn?burn=20" | vegeta attack -rate="${i}/s" -duration="15s" -keepalive=false | vegeta encode -to=csv -output="/tmp/4vegeta${i}.log"
done

exit 0