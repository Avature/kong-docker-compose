#!/bin/bash
touch /var/log/admin-api.log
chmod 666 /var/log/admin-api.log
chmod kong:nogroup /var/log/admin-api.log
mkdir /home/kong/certs
chown kong:nogroup /home/kong/certs
/docker-entrypoint.sh kong docker-start
