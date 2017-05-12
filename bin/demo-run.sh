#!/bin/bash

MINISHIFT_DIRECTORY="$(cd "$(dirname "$0")" && pwd)"
PROJECT=minishift-demo

OPENSHIFT_TOKEN=$(oc whoami -t)
OPENSHIFT_REGISTRY="$(minishift openshift registry)"

echo "Creating demo application..."

echo "=========================="
echo "(1/4) Creating new project..."

oc new-project $PROJECT --display-name="Demo Project" --description="A demo project designed to help you start developing with Minishift" > /dev/null

echo "=========================="
echo "(2/4) Installing node_modules..."

cd "$MINISHIFT_DIRECTORY"/../demo/hello && npm install --quiet && cd - || exit 1

echo "=========================="
echo "(2/4) Create builder image..."

echo "Setting Docker daemon..."
eval "$(minishift docker-env --shell bash)"

echo "Login to Openshift registry..."
docker login -u developer -p "$OPENSHIFT_TOKEN" "$OPENSHIFT_REGISTRY"

echo "Build S2I image..."
docker build -q "$MINISHIFT_DIRECTORY"/../demo/hello -t nearform/hello

echo "Tag S2I Image..."
docker tag nearform/hello "$OPENSHIFT_REGISTRY"/$PROJECT/hello:latest # Push with tag latest

echo "Push to Openshift registry..."
docker push "$OPENSHIFT_REGISTRY"/$PROJECT/hello:latest

echo "=========================="
echo "(4/4) Deploying hello..."

oc new-app -f "$MINISHIFT_DIRECTORY"/../demo/manifests/openshift/nodejs.yaml \
  -p NAME=hello \
  -p PROBE=/healthz \
  -p IMAGE="${OPENSHIFT_REGISTRY}"/$PROJECT/hello:latest \
  -p APP_VOLUME="${MINISHIFT_DIRECTORY}"/../demo/hello \
  -e SERVER_PORT=8080 \
  -e LOG_LEVEL=debug
