#!/bin/bash
/wait-for-postgres.sh $KONG_PG_HOST $KONG_PG_PORT
touch /var/log/admin-api.log
chmod 666 /var/log/admin-api.log
chmod kong:nogroup /var/log/admin-api.log
mkdir /home/kong/certs
chown kong:nogroup /home/kong/certs

/docker-entrypoint.sh "$@"
