#!/bin/bash
mkdir /home/kong/log
chown kong:nogroup /home/kong/log
sed -i 's/\-c\ nginx.conf/\-c\ custom-nginx.conf/g' /docker-entrypoint.sh
/docker-entrypoint.sh kong docker-start
