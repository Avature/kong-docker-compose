#!/bin/bash
openssl genrsa -out star_xcade_net.key -passout pass:${kong1234} 2048

openssl req -new -key star_xcade_net.key -out star_xcade_net.csr -subj "/C=GB/ST=London/L=London/O=Kong/OU=IT/CN=*.kong-server.com"

openssl x509 -req -days 365 -in star_xcade_net.csr -signkey star_xcade_net.key -out star_xcade_net.crt

mv star_xcade_net.crt ./nginx/certs/
mv star_xcade_net.key ./nginx/certs/

rm star_xcade_net.csr
