#!/bin/sh
echo "-> Starting Avature NGINX"

usermod -u ${NGX_UID:-1000} ngx_usr
groupmod -g ${NGX_GID:-1000} ngx_grp

/etc/ssl/createCerts.sh

/app/create-urls.sh
