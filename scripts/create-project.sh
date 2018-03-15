#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT=${PROJECT:=minishift-demo}
APP_NAME=${APP_NAME:=hello-server}

echo "Creating demo application..."

echo "=========================="
echo "(1/4) Applying extra permissions..."

# This adds anyuid and hostaccess security context constraints to default service account
# This is acceptable for a dev environment only
oc login -u system:admin
oc adm policy add-scc-to-user anyuid system:serviceaccount:$PROJECT:default
oc adm policy add-scc-to-user hostaccess system:serviceaccount:$PROJECT:default
echo "developer" | oc login -u developer
echo "=========================="
echo "(2/4) Creating new project..."

oc new-project $PROJECT --display-name="Demo Project" --description="A demo project designed to help you start developing with Minishift" > /dev/null

echo "=========================="
echo "(3/4) Deploying hello-server..."

oc new-app nearform/centos7-s2i-nodejs:8.9.3~https://github.com/nearform/minishift-demo#pathfinders#192 \
  --context-dir=hello-server \

echo "(4/4) Building hello-server Image"
oc expose svc/minishift-demo
