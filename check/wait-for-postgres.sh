#!/bin/sh
# wait-for-postgres.sh

echo ---- ---- KONG_PG_HOST $KONG_PG_HOST
echo ---- ---- KONG_PG_PORT $KONG_PG_PORT
echo "---- ---- ---- ---- Waiting for PostgreSQL - starting ---- ---- ---- ----"
until nc -zvw10 $KONG_PG_HOST $KONG_PG_PORT 2>&1 >/dev/null
do
  echo "---- ---- ---- ---- Waiting for PostgreSQL - sleep 1 ---- ---- ---- ----"
  sleep 1
done
echo "---- ---- ---- ---- Postgresql is ready. ---- ---- ---- ----"
