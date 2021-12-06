#!/bin/bash

if [[ "$1" == "-certs" ]];
then
  ./createDevCerts.sh
fi
docker-compose --env-file dev.env -f docker-compose.yml -f docker-compose.dev.yml up
