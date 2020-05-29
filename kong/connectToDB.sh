#!/bin/bash
cd ..
source .env
docker-compose run db psql postgresql://${KONG_PG_USER}:${KONG_PG_PASSWORD}@db:5432/kong
