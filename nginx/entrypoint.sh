#!/bin/sh
/etc/nginx/conf.d/server_hosts/create-urls.sh
nginx -g daemon off; "@$"
