#!/bin/sh
# make-kong-migrations.sh

if [ -f /check/finished ] 
then
  rm /check/finished
fi

/check/wait-for-postgres.sh

kong migrations bootstrap 
kong migrations up 
kong migrations finish

echo "---- ---- ---- ---- Finished bootstrapping and migrations. ---- ---- ---- ----"
echo 0 > /check/finished
