#!/bin/sh
echo "Starting Avature NGINX"

/etc/nginx/conf.d/server_hosts/create-urls.sh

nginx -g 'daemon off;'
