#!/bin/sh
# wait-for-migrations.sh

while [ ! -f /check/finished.txt ] 
do
  echo "---- ---- ---- ---- wait-for-migrations - sleep 1 ---- ---- ---- ---- ---- ---- "
  sleep 1
done

echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
echo "Migrations cpomplete"
echo "---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- "
rm /check/finished.txt
