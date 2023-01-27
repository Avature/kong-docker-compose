#!/bin/bash
cd $(dirname $0)
cp ../check/wait-for-postgres.sh ./
docker build --network=host . -t ghcr.io/avature/kong-startup:0.0.8
docker push ghcr.io/avature/kong-startup:0.0.8
rm ./wait-for-postgres.sh
