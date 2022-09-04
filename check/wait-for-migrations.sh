#!/bin/sh
# wait-for-migrations.sh

echo "---- ---- ---- ---- wait-for-migrations - starting ---- ---- ---- ---- ---- "
while [ ! -f /check/finished ] 
do
  echo "---- ---- ---- ---- wait-for-migrations - sleep 1 ---- ---- ---- ---- ---- ---- "
  sleep 1
done
echo "---- ---- ---- ---- Migrations cpomplete ---- ---- ---- ----"
rm /check/finished
