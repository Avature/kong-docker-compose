#!/bin/bash
cd $(dirname $0)
docker build . -t ghcr.io/avature/kong-nginx:0.0.9
docker push ghcr.io/avature/kong-nginx:0.0.9
