#!/bin/bash

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage:"
    echo "  ./deploy-kubernetes.sh <environment> <docker tag>"
    echo "Example:"
    echo "  ./deploy-kubernetes.sh test latest"
    echo ""
    echo "Exiting."
    exit 1
fi

# Absolute path this script is in
scriptPath=$(dirname "$0")

# We want to be in this directory please.
pushd $scriptPath

envName=$1
tagName=$2

echo ========================================================
echo Configuring kubectl

mkdir -p ~/.kube
cp kubeconfig ~/.kube/config

echo Done.

echo ========================================================
echo Templating Kubernetes deployment and service defs...

export DOCKER_TAG=$tagName
echo Using tag $DOCKER_TAG
perl -pe 's;(\\*)(\$([a-zA-Z_][a-zA-Z_0-9]*)|\$\{([a-zA-Z_][a-zA-Z_0-9]*)\})?;substr($1,0,int(length($1)/2)).($2&&length($1)%2?$2:$ENV{$3||$4});eg' deployment.yml.template > deployment.yml
perl -pe 's;(\\*)(\$([a-zA-Z_][a-zA-Z_0-9]*)|\$\{([a-zA-Z_][a-zA-Z_0-9]*)\})?;substr($1,0,int(length($1)/2)).($2&&length($1)%2?$2:$ENV{$3||$4});eg' service.yml.template > service.yml

echo ========================================================
cat service.yml
kubectl apply -f service.yml
echo ========================================================
cat deployment.yml
kubectl apply -f deployment.yml
echo ========================================================

echo Done.
echo ========================================================
echo Exiting successfully.
echo ========================================================

# This is more to soothe my sense of order. Absolutely not necessary.
popd