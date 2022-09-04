#!/bin/sh
# wait-for-konga-prepare.sh

set -e

echo "---- ---- ---- ---- wait-for-konga-prepare - starting ---- ---- ---- ---- ---- ---- "
while [ ! -f /check/finished-konga ] 
do
  echo "---- ---- ---- ---- wait-for-konga-prepare - sleep 1 ---- ---- ---- ---- ---- ---- "
  sleep 1
done
echo "---- ---- ---- ---- konga-prepare complete ---- ---- ---- ----"
rm /check/finished-konga

/app/start.sh
