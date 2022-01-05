#!/bin/bash
while true
do
 inotifywait --recursive --exclude .swp -e create -e modify -e delete -e move /etc/nginx/conf.d
 nginx -t
 if [ $? -eq 0 ]
 then
  echo "Reloading Nginx"
  nginx -s reload
 fi
done
