#!/bin/sh
bash -c "/nginx_startup/server_hosts/create-urls.sh"
bash -c "/certs/createCerts.sh"
python createAdmin.py
