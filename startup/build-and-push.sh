#!/bin/bash
docker build -t ghcr.io/avature/kong-startup:0.0.3 -f startup/Dockerfile .
docker push ghcr.io/avature/kong-startup:0.0.3
