#!/bin/bash
docker build . -t ghcr.io/mnofresno/kong-custom
docker push ghcr.io/mnofresno/kong-custom
