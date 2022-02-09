#!/bin/bash
if [ -z "$1" ]; then
  read -p "Type the cluster ingress base URL: " clusterBaseUrl
else
  clusterBaseUrl=$1
fi
cp ingress.yaml.template /tmp/ingress.yaml
sed -i "s|\$CLUSTER_BASE_URL|${clusterBaseUrl}|g" /tmp/ingress.yaml
kubectl apply -f secrets.yaml -f kong-data-volume-local.yaml -f db-deploy.yaml -f kong-deploy.yaml -f konga-deploy.yaml -f /tmp/ingress.yaml
