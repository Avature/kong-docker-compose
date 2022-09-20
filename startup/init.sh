#!/bin/sh

/check/wait-for-postgres.sh

bash -c "/certs_startup/createCerts.sh"

python createAdmin.py
