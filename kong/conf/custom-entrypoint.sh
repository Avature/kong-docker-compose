#!/bin/bash
mkdir /home/kong/log
chown kong:nogroup /home/kong/log
mkdir /home/kong/certs
chown kong:nogroup /home/kong/certs
sed -i 's/\-c\ nginx.conf/\-c\ custom-nginx.conf/g' /docker-entrypoint.sh
/docker-entrypoint.sh kong docker-start
