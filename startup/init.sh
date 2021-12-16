#!/bin/sh

python createAdmin.py
bash -c "/nginx_startup/server_hosts/create-urls.sh"
