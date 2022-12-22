#!/bin/bash
cd $(dirname $0)
./build.sh
docker push ghcr.io/avature/kong:2.1.4.06
