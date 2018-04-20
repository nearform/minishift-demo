#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT=${PROJECT:=minishift-demo}
APP_NAME=${APP_NAME:=hello-server}
APP_VOLUME=$PWD/$APP_NAME

echo "Creating Minishift-Demo"
echo "=========================="
echo "(1/5) Applying extra permissions"
# This adds anyuid and hostaccess security context constraints to default service account
# This is acceptable for a dev environment only
oc login -u system:admin
oc adm policy add-scc-to-user anyuid system:serviceaccount:$PROJECT:default
oc adm policy add-scc-to-user hostaccess system:serviceaccount:$PROJECT:default
echo "developer" | oc login -u developer
echo "=========================="
echo "(2/5) Creating new project"

oc new-project $PROJECT \
  --display-name="Minishift-Demo Project" \
  --description="A project designed to help you start developing with Minishift" \
  > /dev/null

echo "=========================="
echo "(3/5) Configure Build, ImageStream, Service and Route"
# This passes in values to our template for each of the parameters defined
# ${NAME} becomes hello-server in those configs
oc process -f "$DIR"/../openshift/minishift-demo.yaml \
  -p NAMESPACE=$PROJECT \
  -p NAME=$APP_NAME \
  -p PROBE=/healthz \
  -p SERVER_PORT=8080 \
  -p LOG_LEVEL=debug \
  -p APP_VOLUME=$APP_VOLUME | oc create -f -
 
echo "==========================" 
echo "(4/5) Building hello-server Image"
oc start-build $APP_NAME --from-dir $APP_VOLUME 

echo "==========================" 
echo "(5/5) Deploying hello-server Pod"
oc rollout latest dc/$APP_NAME
oc rollout status dc/$APP_NAME
