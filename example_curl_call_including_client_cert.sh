#!/bin/bash

curl -X GET --insecure https://admin.kong-server.com/services/adminApi \
  --cert nginx/certs_for_client_auth/mydomain.com2.crt\
  --key nginx/certs_for_client_auth/each-client.key\
  --header 'apikey: replace-this-string-with-your-api-key'\
  --header 'Content-Type: application/json'\
  --verbose
