#!/bin/bash
docker build -t ghcr.io/avature/konga:0.14.9.01 -f konga/Dockerfile .
docker push ghcr.io/avature/konga:0.14.9.01
