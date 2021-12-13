#!/bin/sh
apk add openssl
apk add bash

cd /app

pip install -r requirements.txt
python createAdmin.py
bash -c "/certs_startup/createCerts.sh"
