#!/bin/bash
current_dir=$(dirname $(realpath "$0"))
cd $current_dir/../

INSTANCE_NAME=$1
CREDENTIAL_TOKEN=MtTpnSoAefoK4UnSlI5KggcbNaJ/DBwX4zaDgp5/2hbCuuD3H4XzW4aigw1u21Z8GLCarB+CWq83ZUuBjuq0uA==
CONSUMER_TAG=description-instanceUUID_f2d1d5bf-892e-43b8-9042-a6a5a4e35399
IP="127.0.0.1"
HOSTS_GATEWAY_LINE='gateway.kong-server.com'
HOSTS_ADMIN_LINE='admin.kong-server.com'
HOSTS_KONGA_LINE='konga.kong-server.com'
HOSTS_ROOT_LINE='kong-server.com'

backup_old_certs() {
  echo "-> Backing-up previous certificates..."
  mkdir certs.backup
  cp -r certs/* certs.backup/
  echo "-> Removing previous certificates..."
  rm certs/*
}

deploy_test_certs() {
  echo "-> Copying new certificates..."
  cp $current_dir/server-ca-cert.crt certs/
  cp $current_dir/server-ca-key.key certs/
  cp $current_dir/server-ssl-key.key certs/
  cp $current_dir/server-ssl-cert.crt certs/

  chmod +r certs/*
}

create_consumer_with_token() {
  echo "-> Deploying consumer credential..."
  sg docker "docker-compose exec nginx curl -X DELETE http://kong:8001/consumers/$INSTANCE_NAME"
  sg docker "docker-compose exec nginx curl -X POST http://kong:8001/consumers -d '{\"username\":\"$INSTANCE_NAME\", \"tags\":[\"instance-admin-client\", \"$CONSUMER_TAG\"]}' -H \"Content-Type: application/json\""
  sg docker "docker-compose exec nginx curl -X POST http://kong:8001/consumers/$INSTANCE_NAME/key-auth -d '{\"key\":\"$CREDENTIAL_TOKEN\"}' -H \"Content-Type: application/json\""
}

add_host_to_hosts_file_if_needed() {
  HOSTNAME=$1
  HOSTS_LINE="$IP\t$HOSTNAME"
  if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
  then
    echo -e "\tfound \"$HOSTNAME\""
  else
    echo -e "\tnot found \"$HOSTNAME\", adding it"
    echo -e "$HOSTS_LINE" >> /etc/hosts
  fi
}

add_hosts_endpoints() {
  echo "-> Adding lines to /etc/hosts"
  add_host_to_hosts_file_if_needed $HOSTS_ROOT_LINE $IP
  add_host_to_hosts_file_if_needed $HOSTS_GATEWAY_LINE $IP
  add_host_to_hosts_file_if_needed $HOSTS_ADMIN_LINE $IP
  add_host_to_hosts_file_if_needed $HOSTS_KONGA_LINE $IP
}

restart_services() {
  echo "-> Restarting services..."
  sg docker "docker-compose restart nginx"
  sg docker "docker-compose restart kong"
}

check_user_is_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run by root' >&2
    exit 1
  fi
}

run_deploy() {
  check_user_is_root
  add_hosts_endpoints
  backup_old_certs
  deploy_test_certs
  create_consumer_with_token
  restart_services
}

run_deploy
