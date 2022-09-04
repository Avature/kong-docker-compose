#!/bin/sh

echo "---- ---- ---- ---- Waiting for PostgreSQL... ---- ---- ---- ----"
until nc -zvw10 $KONG_PG_HOST $KONG_PG_PORT 2>&1 >/dev/null
do
  echo "---- ---- ---- ---- Waiting for PostgreSQL... ---- ---- ---- ----"
  sleep 1
done
echo "---- ---- ---- ---- Postgresql is ready ... ---- ---- ---- ----"

bash -c "/certs_startup/createCerts.sh"

python createAdmin.py
