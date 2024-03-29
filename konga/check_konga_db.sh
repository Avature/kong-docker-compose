#!/bin/bash
echo "-> Waiting for konga_db bootstrap..."
while ! psql postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST/konga_db -c '\d konga_users' &> /dev/null; do
  echo "--- konga_db not ready, please wait ---"
  sleep 1
done
echo "Table 'konga_user' now exists running Konga..."

