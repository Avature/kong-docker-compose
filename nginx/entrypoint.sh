#!/bin/sh
echo "Starting Avature NGINX"

/etc/ssl/createCerts.sh

/app/create-urls.sh
