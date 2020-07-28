#!/bin/bash
envsubst '$${BASE_HOST_DOMAIN}' < /etc/nginx/conf.d/server_hosts/admin-url.conf.template > /etc/nginx/conf.d/server_hosts/admin-url.conf
envsubst '$${BASE_HOST_DOMAIN}' < /etc/nginx/conf.d/server_hosts/gateway-url.conf.template > /etc/nginx/conf.d/server_hosts/gateway-url.conf
envsubst '$${BASE_HOST_DOMAIN}' < /etc/nginx/conf.d/server_hosts/konga-url.conf.template > /etc/nginx/conf.d/server_hosts/konga-url.conf
nginx -g 'daemon off;'
