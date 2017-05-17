#!/bin/bash

MINISHIFT_DIRECTORY="$(cd "$(dirname "$0")" && pwd)"
PROJECT=${PROJECT:=minishift-demo}
APP_NAME=${APP_NAME:=hello-server}

echo "Creating demo application..."

echo "=========================="
echo "(1/4) Applying extra permissions..."

# This adds anyuid and hostaccess security context constraints to default service account
# This is acceptable for a dev environment only
oc login -u system:admin > /dev/null
oc adm policy add-scc-to-user anyuid system:serviceaccount:$PROJECT:default
oc adm policy add-scc-to-user hostaccess system:serviceaccount:$PROJECT:default
oc login -u developer > /dev/null

echo "=========================="
echo "(2/4) Creating new project..."

oc new-project $PROJECT --display-name="Demo Project" --description="A demo project designed to help you start developing with Minishift" > /dev/null

echo "=========================="
echo "(3/4) Deploying hello-server..."

oc process -f "$MINISHIFT_DIRECTORY"/../demo/manifests/openshift/nodejs.yaml \
  -p NAMESPACE=$PROJECT \
  -p NAME=$APP_NAME \
  -p PROBE=/healthz \
  -p SERVER_PORT=8080 \
  -p LOG_LEVEL=debug \
  -p APP_VOLUME="${MINISHIFT_DIRECTORY}"/../demo/hello | oc create -f -

echo "(4/4) Building hello-server Image"
oc start-build $APP_NAME --from-dir $MINISHIFT_DIRECTORY/../demo/hello
