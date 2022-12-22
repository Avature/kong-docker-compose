#!/bin/bash
docker build . -t ghcr.io/avature/kong-nginx:0.0.8
docker push ghcr.io/avature/kong-nginx:0.0.8
