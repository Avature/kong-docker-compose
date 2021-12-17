#!/bin/sh

bash -c "/nginx_startup/server_hosts/create-urls.sh"

python createAdmin.py
