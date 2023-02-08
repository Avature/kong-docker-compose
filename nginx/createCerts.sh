#!/bin/bash

readConfigFromDotEnv() {
  export $(cat .env | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//' | sed '/^#/d' | xargs)
}

initializeConfigVariables() {
  if [ -z "$BASE_HOST_DOMAIN" ]
  then
    server_ca_cn=kong-server.com
  else
    server_ca_cn=$BASE_HOST_DOMAIN
  fi

  server_ca_path=certs/server-ca
  server_ssl_path=certs/server-ssl

  server_ca_key="$server_ca_path-key.key"
  server_ca_cert="$server_ca_path-cert.crt"
  server_ssl_key="$server_ssl_path-key.key"
  server_ssl_cert="$server_ssl_path-cert.crt"
  server_ssl_csr="$server_ssl_path-csr.csr"
  server_ssl_cn="*.$server_ca_cn"
}

create_ca_certs() {
  echo "-> Creating CA certificates..."
  openssl genrsa -des3 -out $server_ca_key -passout pass:1234 2048
  openssl req -new -key $server_ca_key -subj "/C=US/ST=CA/O=Avature/CN=$server_ca_cn" -x509 -days 1000 -out $server_ca_cert -passin pass:1234
}

create_ssl_server_certs() {
  echo "-> Creating SSL certificates..."
  openssl genrsa -out $server_ssl_key 2048
  openssl req -new -key $server_ssl_key -out $server_ssl_csr -subj "/C=GB/ST=London/L=London/O=Avature/OU=IT/CN=$server_ca_cn/subjectAltName=$server_ssl_cn"
  openssl x509 -req -days 365 -in $server_ssl_csr -CA $server_ca_cert -CAkey $server_ca_key -CAcreateserial -out $server_ssl_cert -sha256 -passin pass:1234
}

normalize_permissions() {
  chmod +r ./$server_ca_key
  chmod +r ./$server_ca_cert
  chmod +r ./$server_ssl_key
  chmod +r ./$server_ssl_cert
}

normalize_owner() {
  chown nginx_usr:nginx_grp certs
  chown nginx_usr:nginx_grp ./$server_ca_key
  chown nginx_usr:nginx_grp ./$server_ca_cert
  chown nginx_usr:nginx_grp ./$server_ssl_key
  chown nginx_usr:nginx_grp ./$server_ssl_cert
}

setup_certs() {
  cd /etc/ssl
  readConfigFromDotEnv
  initializeConfigVariables

  mkdir -p certs
  rm certs/*.csr

  if [[ ! -f "$server_ca_cert" ]]
  then
    create_ca_certs
    normalize_owner
  fi

  if [ "$CREATE_SSL_CERTS" == "true" ];
  then
    create_ssl_server_certs
    normalize_owner
  fi
  normalize_permissions
}

setup_certs $1
