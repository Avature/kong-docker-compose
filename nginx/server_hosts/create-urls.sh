#!/bin/bash
envsubst '$${BASE_HOST_DOMAIN}' < /etc/nginx/server_hosts/admin-url.conf.template > /etc/nginx/server_hosts/admin-url.conf
envsubst '$${BASE_HOST_DOMAIN}' < /etc/nginx/server_hosts/gateway-url.conf.template > /etc/nginx/server_hosts/gateway-url.conf
envsubst '$${BASE_HOST_DOMAIN}' < /etc/nginx/server_hosts/konga-url.conf.template > /etc/nginx/server_hosts/konga-url.conf
