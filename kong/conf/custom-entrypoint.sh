#!/bin/bash
/wait-for-postgres.sh $KONG_PG_HOST $KONG_PG_PORT

echo "-> Setting up UID GID for KONG"

usermod -u ${AVATURE_KONG_UID:-1000} kong_usr
groupmod -g ${AVATURE_KONG_GID:-1000} kong_grp

echo "-> Create admin-api log and fix permissions"

touch /var/log/admin-api.log
chmod 666 /var/log/admin-api.log
chown kong_usr:kong_grp /home/kong/certs
chown -R kong_usr:kong_grp /var/log

echo "-> Starting kong..."

/docker-entrypoint.sh "$@"
