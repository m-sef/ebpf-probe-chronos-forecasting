#!/usr/bin/env bash

for (( i = 10; i < 100; i += 10 )); do
    echo "GET http://10.10.1.1:8080/burn?burn=20" | vegeta attack -rate="$i/s" -duration="10s" -keepalive=false | vegeta encode -to=csv -output="/tmp/vegeta${i}.log"
done

exit 0