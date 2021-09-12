#!/bin/bash
kubectl apply -f secrets.yaml -f kong-data-volume.yaml -f db-deploy.yaml -f kong-deploy.yaml -f konga-deploy.yaml -f ingress.yaml
