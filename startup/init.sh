#!/bin/sh

echo "---- ---- ---- ---- Waiting for PostgreSQL... ---- ---- ---- ----"
until nc -zvw10 db 5432 2>&1 >/dev/null
do
  echo "---- ---- ---- ---- Waiting for PostgreSQL... ---- ---- ---- ----"
  sleep 1
done
echo "---- ---- ---- ---- Postgresql is ready ... ---- ---- ---- ----"

bash -c "/certs_startup/createCerts.sh"

python createAdmin.py
