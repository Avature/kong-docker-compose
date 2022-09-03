#!/bin/bash
/check/wait-for-migrations.sh

chown kong:nogroup /home/kong/certs
/docker-entrypoint.sh kong docker-start
