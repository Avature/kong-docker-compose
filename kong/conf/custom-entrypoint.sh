#!/bin/bash
/wait-for-postgres.sh $KONG_PG_HOST $KONG_PG_PORT

usermod -u ${AVATURE_KONG_UID:-1000} kong_usr
groupmod -g ${AVATURE_KONG_GID:-1000} kong_grp

touch /var/log/admin-api.log
chmod 666 /var/log/admin-api.log
chown kong_usr:kong_grp /home/kong/certs
chown -R kong_usr:kong_grp /var/log
/docker-entrypoint.sh "$@"
