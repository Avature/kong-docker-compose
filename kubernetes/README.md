# This is the migration of the Kong-Docker-Compose project to Kubernetes

To deploy this software we need to run:

KUBECONFIG=$HOME/.kube/{your-json-kubeconfig-credential-file} ./apply.sh

To remove the deploy from your cluster we need to run:

KUBECONFIG=$HOME/.kube/{your-json-kubeconfig-credential-file} ./delete.sh

