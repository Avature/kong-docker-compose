#!/bin/sh
# wait-for-konga-prepare.sh

set -e

echo "---- ---- ---- ---- wait-for-konga-prepare - starting ---- ---- ---- ---- ---- ---- "
while [ ! -f /check/finished-konga.txt ] 
do
  echo "---- ---- ---- ---- wait-for-konga-prepare - sleep 1 ---- ---- ---- ---- ---- ---- "
  sleep 1
done

echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
echo "---- ---- ---- ---- konga-prepare complete ---- ---- ---- ----"
echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
rm /check/finished-konga.txt

/docker-entrypoint.sh $@
