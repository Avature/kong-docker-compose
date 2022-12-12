#!/bin/bash
cp ../check/wait-for-postgres.sh ./
docker build . -t ghcr.io/avature/kong-startup:0.0.4
docker push ghcr.io/avature/kong-startup:0.0.4
rm ./wait-for-postgres.sh
