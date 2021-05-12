#!/bin/bash
source .env

if [ -z "$BASE_HOST_DOMAIN" ]
then
  server_ca_cn=kong-server.com
else
  server_ca_cn=$BASE_HOST_DOMAIN
fi

server_ca_key=certs/server-ca-key.key
server_ca_cert=certs/server-ca-cert.crt
server_ssl_key=certs/server-ssl-key.key
server_ssl_cert=certs/server-ssl-cert.crt
server_ssl_csr=certs/server-ssl.csr
server_ssl_cn="*.$server_ca_cn"

create_ca_certs() {
  echo "Creating CA certificates..."
  openssl genrsa -des3 -out $server_ca_key -passout pass:1234 2048
  openssl req -new -key $server_ca_key -subj "/C=US/ST=CA/O=Avature/CN=$server_ca_cn" -x509 -days 1000 -out $server_ca_cert -passin pass:1234
}

create_ssl_server_certs() {
  echo "Creating SSL certificates..."
  openssl genrsa -out $server_ssl_key 2048
  openssl req -new -key $server_ssl_key -out $server_ssl_csr -subj "/C=GB/ST=London/L=London/O=Avature/OU=IT/CN=$server_ssl_cn"
  openssl x509 -req -days 365 -in $server_ssl_csr -CA $server_ca_cert -CAkey $server_ca_key -CAcreateserial -out $server_ssl_cert -sha256 -passin pass:1234
}

mkdir certs
rm certs/*.csr

if [[ ! -f "$server_ca_cert" ]]
then
  create_ca_certs
fi

if [[ "$1" == "-ssl" ]];
then
  create_ssl_server_certs
fi

chmod +r ./certs/*
