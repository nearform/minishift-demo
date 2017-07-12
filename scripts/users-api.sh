#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT=${PROJECT:=minishift-demo}

if [ "$1" == "up" ]; then
  oc process -f "$DIR"/../openshift/users-api.yaml -p NAMESPACE=$PROJECT | oc create -f -
elif [ "$1" == "down" ]; then
  oc process -f "$DIR"/../openshift/users-api.yaml -p NAMESPACE=$PROJECT | oc delete -f -
else
  echo -e "USAGE:\n./users-api.sh up\t# Create the users-api resources\n./users-api.sh down\t# Delete the user-api-resources"
fi