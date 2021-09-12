#!/bin/bash
kubectl apply -f kong-data-volume.yaml -f konga-deploy.yaml -f kong-deploy.yaml -f db-deploy.yaml -f ingress.yaml -f secrets.yaml

