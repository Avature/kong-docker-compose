#!/bin/bash
docker build . -t ghcr.io/avature/kong:2.1.4.01
docker push ghcr.io/avature/kong:2.1.4.01
