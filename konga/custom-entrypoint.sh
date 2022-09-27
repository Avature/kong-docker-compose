#!/bin/bash

/wait-for-postgres.sh $DB_HOST $DB_PORT

exec /app/start.sh "$@"
