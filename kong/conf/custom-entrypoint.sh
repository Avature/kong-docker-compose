#!/bin/bash
/wait-for-postgres.sh $KONG_PG_HOST $KONG_PG_PORT
touch /var/log/admin-api.log
chmod 666 /var/log/admin-api.log
chown kong_usr:kong_grp /home/kong/certs
chown -R kong_usr:kong_grp /var/log
/docker-entrypoint.sh "$@"
