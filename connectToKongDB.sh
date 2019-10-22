#!/bin/bash
docker-compose run db psql postgresql://${KONG_PG_USER:-kong}:${KONG_PG_PASSWORD:-kong}@db:5432/kong
