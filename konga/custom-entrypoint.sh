#!/bin/bash

/wait-for-postgres.sh $DB_HOST $DB_PORT

if [ $# -eq 0 ]
then
  /check_konga_db.sh
fi

exec /app/start.sh "$@"
