#!/bin/sh

bash -c "/nginx_startup/server_hosts/create-urls.sh"
bash -c "/certs_startup/createCerts.sh"

python createAdmin.py
