#!/bin/bash
mkdir -p /home/kong/log
# below chown command fails. Is left by legacy but must be considered its avoiding ...
chown kong:nogroup /home/kong/log
mkdir -p /home/kong/certs

/check/wait-for-migrations.sh

chown kong:nogroup /home/kong/certs
/docker-entrypoint.sh kong docker-start
