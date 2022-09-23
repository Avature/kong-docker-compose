#!/bin/bash

/wait-for-postgres.sh $KONG_PG_HOST $KONG_PG_PORT

chown kong:nogroup /home/kong/certs

/docker-entrypoint.sh "$@"
