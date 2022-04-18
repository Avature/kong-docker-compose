#!/bin/bash
echo -n "Press ENTER key if you sure that you want to remove all the environment from your cluster. Otherwise press Ctrl+C to Cancel."
read
kubectl delete -f kong-data-volume-local.yaml -f konga-deploy.yaml -f kong-deploy.yaml -f db-deploy.yaml -f secrets.yaml -f ingress.yaml.template

