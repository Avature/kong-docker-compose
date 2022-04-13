#!/bin/sh
echo "Starting Avature NGINX"

/app/create-urls.sh

nginx -g 'daemon off;'
