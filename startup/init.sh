#!/bin/sh
apk add gettext
apk add bash

cd /app

pip install -r requirements.txt
python createAdmin.py
bash -c "/nginx_startup/server_hosts/create-urls.sh"
