#!/bin/sh

echo "-> Setting up UID GID for NGINX"

usermod -u ${AVATURE_KONG_UID:-1000} ngx_usr
groupmod -g ${AVATURE_KONG_GID:-1000} ngx_grp

echo "-> Starting Avature NGINX"

/etc/ssl/createCerts.sh

/app/create-urls.sh
