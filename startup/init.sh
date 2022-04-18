#!/bin/sh

bash -c "/certs_startup/createCerts.sh"

python createAdmin.py
