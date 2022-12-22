#!/bin/bash
cd $(dirname $0)
cp ../check/wait-for-postgres.sh ./
docker build -t ghcr.io/avature/konga:0.14.9.01 .
docker push ghcr.io/avature/konga:0.14.9.01
rm ./wait-for-postgres.sh
