#!/bin/bash

echo "Installing Docker-Compose"

curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose


chmod +x /usr/local/bin/docker-compose

echo "Running Contract Tests..."

docker-compose --env-file dev.env -f docker-compose.yml -f docker-compose.test.yml up
