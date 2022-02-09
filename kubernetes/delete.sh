#!/bin/bash
read -p "Are you sure that you want to remove all the environment from your cluster? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  kubectl delete -f kong-data-volume.yaml -f konga-deploy.yaml -f kong-deploy.yaml -f db-deploy.yaml -f secrets.yaml -f ingress.yaml.template
else
  echo -e "Operation cancelled"
fi
