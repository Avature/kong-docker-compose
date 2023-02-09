#!/bin/sh
echo "-> Starting Avature NGINX"

usermod -u ${AVATURE_KONG_UID:-1000} ngx_usr
groupmod -g ${AVATURE_KONG_GID:-1000} ngx_grp

/etc/ssl/createCerts.sh

/app/create-urls.sh
