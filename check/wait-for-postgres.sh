#!/bin/sh
# wait-for-postgres.sh

check_pgsql() {
  echo ---- ---- KONG_PG_HOST $1
  echo ---- ---- KONG_PG_PORT $2
  echo "---- ---- ---- ---- Waiting for PostgreSQL - starting ---- ---- ---- ----"
  until nc -zvw10 $1 $2 2>&1 >/dev/null
  do
    echo "---- ---- ---- ---- Waiting for PostgreSQL - sleep 1 ---- ---- ---- ----"
    sleep 1
  done
  echo "---- ---- ---- ---- Postgresql is ready. ---- ---- ---- ----"
}

check_pgsql $1 $2
