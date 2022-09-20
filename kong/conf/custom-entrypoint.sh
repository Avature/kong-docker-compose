#!/bin/bash
#/check/wait-for-migrations.sh
/check/wait-for-postgres.sh

chown kong:nogroup /home/kong/certs
/docker-entrypoint.sh kong docker-start
