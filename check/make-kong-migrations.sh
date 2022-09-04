#!/bin/sh
# make-kong-migrations.sh

if [ -f /check/finished ] 
then
  rm /check/finished
fi

echo ---- ---- KONG_PG_HOST $KONG_PG_HOST
echo ---- ---- KONG_PG_PORT $KONG_PG_PORT
echo ---- ---- KONG_PG_USER $KONG_PG_USER
echo ---- ---- KONG_PG_PASSWORD $KONG_PG_PASSWORD
echo "---- ---- ---- ---- Waiting for PostgreSQL - starting ---- ---- ---- ----"
until nc -zvw10 $KONG_PG_HOST $KONG_PG_PORT 2>&1 >/dev/null
do
  echo "---- ---- ---- ---- Waiting for PostgreSQL - sleep 1 ---- ---- ---- ----"
  sleep 1
done

echo "---- ---- Postgresql is ready. Starting bootstrapping and migrations ... ---- ----"

kong migrations bootstrap 
kong migrations up 
kong migrations finish

echo "---- ---- ---- ---- Finished bootstrapping and migrations. ---- ---- ---- ----"
echo 0 > /check/finished
