#!/bin/bash
docker-compose --env-file dev.env -f docker-compose.yml -f docker-compose.dev.yml up
