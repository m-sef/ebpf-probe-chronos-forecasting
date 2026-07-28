#!/usr/bin/env bash

for (( i = 10; i <= 100; i += 10 )); do
    echo "${i}/s"
    echo "GET http://10.10.1.1:8080/burn?burn=20" | vegeta attack -rate="${i}/s" -duration="10s" -keepalive=false | vegeta encode -to=csv -output="/tmp/1vegeta${i}.log"
done

for (( i = 90; i > 0; i -= 10 )); do
    echo "${i}/s"
    echo "GET http://10.10.1.1:8080/burn?burn=20" | vegeta attack -rate="${i}/s" -duration="10s" -keepalive=false | vegeta encode -to=csv -output="/tmp/2vegeta${i}.log"
done

exit 0