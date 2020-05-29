#!/bin/bash
cd $(dirname $0)/../
source .env
docker-compose run db psql postgresql://${KONG_PG_USER}:${KONG_PG_PASSWORD}@db:5432/konga_db
