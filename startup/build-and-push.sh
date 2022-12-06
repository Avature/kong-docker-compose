#!/bin/bash
docker build . -t ghcr.io/avature/kong-startup:0.0.2
docker push ghcr.io/avature/kong-startup:0.0.2
