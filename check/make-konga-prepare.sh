#!/bin/sh
# make-konga-prepare.sh

if [ -f /check/finished-konga.txt ] 
then
  rm /check/finished-konga.txt
fi

  echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
  echo "---- ---- ---- ---- Waiting for PostgreSQL... ---- ---- ---- ----"
  echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
until nc -zvw10 db 5432 2>&1 >/dev/null
do
  echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
  echo "---- ---- ---- ---- Waiting for PostgreSQL... ---- ---- ---- ----"
  echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
  sleep 1
done

echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
echo "---- ---- ---- ---- Postgresql is ready ... Starting konga-prepare ... ---- ---- ---- ----"
echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "

echo KONG_PG_USER $KONG_PG_USER
echo KONG_PG_PASSWORD $KONG_PG_PASSWORD
node ./bin/konga.js prepare --adapter postgres --uri postgresql://$KONG_PG_USER:$KONG_PG_PASSWORD@db:5432/konga_db

echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
echo "---- ---- ---- ---- Finished bootstrapping and migrations. ---- ---- ---- ----"
echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
echo 0 > /check/finished-konga.txt
