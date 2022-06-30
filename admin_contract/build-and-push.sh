#!/bin/bash
docker build . -t ghcr.io/avature/kong-contract-tests:0.0.2
docker push ghcr.io/avature/kong-contract-tests:0.0.2
