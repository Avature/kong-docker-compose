#!/bin/bash
cd $(dirname $0)
cp ../check/wait-for-postgres.sh ./
docker build . -t ghcr.io/avature/kong-startup:0.0.6
docker push ghcr.io/avature/kong-startup:0.0.6
rm ./wait-for-postgres.sh
