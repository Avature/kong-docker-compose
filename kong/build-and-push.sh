#!/bin/bash
docker build -t ghcr.io/avature/kong:2.1.4.05 -f kong/Dockerfile .
docker push ghcr.io/avature/kong:2.1.4.05

