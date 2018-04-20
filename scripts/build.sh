#!/bin/bash

APP_NAME=${APP_NAME:=hello-server}
APP_VOLUME=$PWD/$APP_NAME

echo "logged in as developer" | oc login -u developer
echo "==========================" 
echo "(1/2) Building hello-server Image"
oc start-build $APP_NAME --from-dir $APP_VOLUME 

echo "==========================" 
echo "(2/2) Deploying hello-server Pod"
oc rollout latest dc/$APP_NAME
oc rollout status dc/$APP_NAME
