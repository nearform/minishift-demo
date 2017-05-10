#!/bin/bash

set -e

MINISHIFT_DIRECTORY="$(dirname $PWD)"
PROJECT=hello

OPENSHIFT_TOKEN=$(oc whoami -t)
OPENSHIFT_REGISTRY="$(minishift openshift registry)"

echo "Creating demo application..."
echo "=========================="
echo "(1/5) Creating new project..."
oc new-project $PROJECT --display-name="Hello Project" --description="This is initial setup for Hello project" > /dev/null

echo "=========================="
echo "(2/5) Create builder image..."
echo "Setting Docker daemon..."
eval "$(minishift docker-env --shell bash)"
echo "Login to Openshift registry..."
docker login -u developer -p $OPENSHIFT_TOKEN $OPENSHIFT_REGISTRY > /dev/null
echo "Build S2I image..."
docker build -q $MINISHIFT_DIRECTORY/s2i-images/node-7.10.0 -t nearform/node:7.10.0
echo "Tag S2I Image"
docker tag nearform/node:7.10.0 $OPENSHIFT_REGISTRY/$PROJECT/node:7.10.0
docker tag nearform/node:7.10.0 $OPENSHIFT_REGISTRY/$PROJECT/node:latest # Push with tag latest
echo "Push to Openshift registry..."
docker push $OPENSHIFT_REGISTRY/$PROJECT/node:7.10.0
docker push $OPENSHIFT_REGISTRY/$PROJECT/node:latest

echo "=========================="
echo "(3/5) Deploying Mosquitto..."
oc create -f $MINISHIFT_DIRECTORY/demo/manifests/mosquitto.yaml > /dev/null

sleep 5

echo "=========================="
echo "(4/5) Deploying server..."
oc process -f $MINISHIFT_DIRECTORY/demo/manifests/nodejs.yaml -p NAME=server -p PROBE=/healthz | oc create -f - 
oc set env dc/server SERVER_PORT=8080 LOG_LEVEL=debug MQTT_BROKER=mqtt://eclipse-mosquitto
oc start-build server --from-dir $MINISHIFT_DIRECTORY/demo/server

sleep 5

echo "=========================="
echo "(5/5) Deploying client..."
oc process -f $MINISHIFT_DIRECTORY/demo/manifests/nodejs.yaml -p NAME=client -p PROBE=/healthz | oc create -f -
oc set env dc/client SERVER_PORT=8080 LOG_LEVEL=debug MQTT_BROKER=mqtt://eclipse-mosquitto
oc start-build client --from-dir $MINISHIFT_DIRECTORY/demo/client