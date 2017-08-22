#!/bin/bash

set -eo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT=${PROJECT:=openshift-demo}
APP_NAME=${APP_NAME:=hello-server}
SSH_KEY=${SSH_KEY:=deploy}
GIT_REPO=git@github.com:username/minishift-demo.git
GIT_DIR=hello-server

command -v oc > /dev/null 2>&1 || { echo >&2 "The oc is required to run this script."; exit 1; }

echo "Creating demo application..."

echo "=========================="
echo "(1/5) Creating new project..."
oc new-project $PROJECT --display-name="Demo Project" --description="A demo project designed to help you start developing with Openshift" > /dev/null

echo "=========================="
echo "(2/5) Create Source Clone secret..."
oc secrets new-sshauth sshsecret --ssh-privatekey="$HOME"/.ssh/"$SSH_KEY" > /dev/null
oc secrets link builder sshsecret

echo "=========================="
echo "(3/5) Save template..."
oc create -f "$DIR"/../openshift/openshift-demo.yaml

echo "=========================="
echo "(4/5) Deploying ${APP_NAME}..."
oc new-app \
  --template=openshift-demo \
  --param NAMESPACE=$PROJECT \
  --param NAME=$APP_NAME \
  --param PROBE=/healthz \
  --param SOURCE_REPOSITORY_URL=$GIT_REPO \
  --param CONTEXT_DIR=$GIT_DIR \
  --param LOG_LEVEL=info \
  --param NODE_ENV=staging \
  --param SERVER_PORT=8080