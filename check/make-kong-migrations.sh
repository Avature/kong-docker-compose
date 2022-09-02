#!/bin/sh
# make-kong-migrations.sh

if [ -f /check/finished.txt ] 
then
  rm /check/finished.txt
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
echo "---- ---- ---- ---- Postgresql is ready ... Starting bootstrapping and migrations ... ---- ---- ---- ----"
echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "

kong migrations bootstrap 
kong migrations up 
kong migrations finish

echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
echo "---- ---- ---- ---- Finished bootstrapping and migrations. ---- ---- ---- ----"
echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
echo 0 > /check/finished.txt
