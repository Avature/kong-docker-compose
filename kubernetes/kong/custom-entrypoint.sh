#!/bin/bash
mkdir /home/kong/log
chown kong:nogroup /home/kong/log
mkdir /home/kong/certs
chown kong:nogroup /home/kong/certs
sed -i 's/worker\_processes auto\;/worker\_processes $NGINX_WORKER_PROCESSES\;/g' /usr/local/kong/nginx.conf
/docker-entrypoint.sh kong docker-start
