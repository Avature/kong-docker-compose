#!/bin/bash
cd $(dirname $0)
cp ../check/wait-for-postgres.sh ./
docker build . -t ghcr.io/avature/kong-startup:0.0.5
docker push ghcr.io/avature/kong-startup:0.0.5
rm ./wait-for-postgres.sh
