#!/bin/bash
mkdir /home/kong/log
chown kong:nogroup /home/kong/log
mkdir /home/kong/certs
chown kong:nogroup /home/kong/certs
/docker-entrypoint.sh kong docker-start
