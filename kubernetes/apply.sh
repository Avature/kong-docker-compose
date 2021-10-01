#!/bin/bash
clusterBaseUrl=$1
if [ -z "$clusterBaseUrl" ]; then
  echo -n "Type the cluster ingress base URL: ";
  read;
  clusterBaseUrl=${REPLY}
fi
if [ -z "$clusterBaseUrl" ]; then
  echo "Invalid input";
  exit;
fi
cp ingress.yaml.template /tmp/ingress.yaml
sed -i "s|\$CLUSTER_BASE_URL|${clusterBaseUrl}|g" /tmp/ingress.yaml
kubectl apply -f secrets.yaml -f kong-data-volume.yaml -f db-deploy.yaml -f kong-deploy.yaml -f konga-deploy.yaml -f /tmp/ingress.yaml
