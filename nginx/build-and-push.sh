#!/bin/bash
docker build . -t ghcr.io/avature/kong-nginx:0.0.7
docker push ghcr.io/avature/kong-nginx:0.0.7
