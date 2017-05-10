#!/bin/bash

# set -e

MINISHIFT_DIRECTORY="$(dirname $PWD)"
PROJECT=minishift-demo

OPENSHIFT_TOKEN=$(oc whoami -t)

echo "Creating demo application..."
echo "=========================="
echo "(1/5) Creating new project..."
oc new-project $PROJECT --display-name="Demo Project" --description="A demo project designed to help you start developing with minishift" > /dev/null

echo "=========================="

if oc get builds node > /dev/null; then
  echo "(2/5) node-6-builder exists. Skipping..."
else
  echo "(2/5) Creating node-6-builder image"
  oc create -f ../demo/manifests/node-s2i.yml
  oc start-build node --from-dir ../s2i-images/node-7.10.0 --follow
fi


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