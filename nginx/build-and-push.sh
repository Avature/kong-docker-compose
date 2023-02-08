#!/bin/bash
cd $(dirname $0)
docker build . -t ghcr.io/avature/kong-nginx:0.1.0
docker push ghcr.io/avature/kong-nginx:0.1.0
