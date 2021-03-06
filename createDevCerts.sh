#!/bin/bash
server_ca_key=certs/server-ca-key.key
server_ca_cert=certs/server-ca-cert.crt
server_ca_cn=kong-server.com
server_ssl_key=certs/server-ssl-key.key
server_ssl_cert=certs/server-ssl-cert.crt
server_ssl_csr=certs/server-ssl.csr
server_ssl_cn=*.kong-server.com

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
chmod +r ./certs/*

create_ca_certs

if [[ "$1" == "-ssl" ]];
then
  create_ssl_server_certs
fi
