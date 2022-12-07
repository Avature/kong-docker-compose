#!/bin/bash
cp ../check/wait-for-postgres.sh ./
docker build . -t ghcr.io/avature/kong:2.1.4.06
rm ./wait-for-postgres.sh
