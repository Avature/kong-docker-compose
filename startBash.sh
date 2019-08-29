#!/bin/bash
docker exec -it $(docker ps -f name=kong_kong_ --format "{{.ID}}") /bin/bash
