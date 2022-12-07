#!/bin/bash
docker build . -t ghcr.io/avature/kong:2.1.4.06
docker push ghcr.io/avature/kong:2.1.4.06
