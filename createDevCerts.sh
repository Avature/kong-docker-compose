#!/bin/bash
openssl genrsa -out cert.key -passout pass:${kong1234} 2048

openssl req -new -key cert.key -out cert.csr -subj "/C=GB/ST=London/L=London/O=Kong/OU=IT/CN=*.com"

openssl x509 -req -days 365 -in cert.csr -signkey cert.key -out cert.crt

mv cert.crt ./nginx/certs/
mv cert.key ./nginx/certs/

rm cert.csr
