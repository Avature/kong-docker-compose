#!/bin/sh
# make-konga-prepare.sh

if [ -f /check/finished-konga ] 
then
  rm /check/finished-konga
fi

echo ---- ---- KONG_PG_USER $KONG_PG_USER
echo ---- ---- KONG_PG_PASSWORD $KONG_PG_PASSWORD
/check/wait-for-postgres.sh

node ./bin/konga.js prepare --adapter postgres --uri postgresql://$KONG_PG_USER:$KONG_PG_PASSWORD@$KONG_PG_HOST:$KONG_PG_PORT/konga_db

echo "---- ---- ---- ---- Finished bootstrapping and migrations. ---- ---- ---- ----"
echo 0 > /check/finished-konga
