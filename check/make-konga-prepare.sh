#!/bin/sh
# make-konga-prepare.sh

if [ -f /check/finished-konga ] 
then
  rm /check/finished-konga
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

echo "---- ---- Postgresql is ready. Starting konga-prepare ... ---- ----"

node ./bin/konga.js prepare --adapter postgres --uri postgresql://$KONG_PG_USER:$KONG_PG_PASSWORD@$KONG_PG_HOST:$KONG_PG_PORT/konga_db

echo "---- ---- ---- ---- Finished bootstrapping and migrations. ---- ---- ---- ----"
echo 0 > /check/finished-konga
