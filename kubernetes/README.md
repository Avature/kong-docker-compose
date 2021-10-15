# This is the migration of the Kong-Docker-Compose project to Kubernetes

To deploy this software we need to run:

KUBECONFIG=$HOME/.kube/{your-json-kubeconfig-credential-file} ./apply.sh {your-cluster's-base-url}

To remove the deploy from your cluster we need to run:

KUBECONFIG=$HOME/.kube/{your-json-kubeconfig-credential-file} ./delete.sh

# TODO

We need to have a way to configure the number of NGINX workers via an env variable, a valid approach could be something like this:

sed -i 's/worker\_processes auto\;/worker\_processes $NGINX_WORKER_PROCESSES\;/g' /usr/local/kong/nginx.conf


# LAST CHANGES

* Add start markup to where it were missing
* Add double check to delete script to avoid accidental triggering
* Convert kong token into secret
* Remove namepace
* Add image pull policy
* Add requested/limit resources
* Add fixed image tag
