#!/bin/bash

set -e

latest_release () {
  curl -L -s -H 'Accept: application/json' "$1" | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/'  
}

extract () {
  mkdir "$2"
  echo "Extracting archive..."
  tar -xzf "$1" -C "$2"
}

OS_TYPE=$(uname -s)

echo "(1/4) Installing minishift..."
LATEST_RELEASE=$(latest_release https://github.com/minishift/minishift/releases/latest)
FILE=minishift.tgz
DIR=./minishift

curl -sL https://github.com/minishift/minishift/releases/download/"${LATEST_RELEASE}"/minishift-"${LATEST_RELEASE:1}"-"${OS_TYPE}"-amd64.tgz -o $FILE
extract $FILE $DIR

echo "(2/4) Where do you want to copy the executable? (default: /usr/local/bin)"
read -r MINISHIFT_PATH

if [[ -z $MINISHIFT_PATH ]]; then
  MINISHIFT_PATH=/usr/local/bin
fi

cp $DIR/minishift $MINISHIFT_PATH
rm -rf $FILE $DIR

echo "(3/4) Which hypervisor do you want to use? (recommended: virtualbox)?"
[[ "$OS_TYPE" == "Darwin" ]] && echo "(xhyve, virtualbox, vmware-fusion)" || echo "(kvm, virtualbox)"
read -r HYPERVISOR

if [[ -z $HYPERVISOR ]]; then
  HYPERVISOR=virtualbox
fi

echo "(4/4) Starting Minishift..."
minishift start --vm-driver $HYPERVISOR

echo "Please login as system admin: oc login -u system:admin"
echo "Run oc edit scc restricted"
echo "Set allowHostDirVolumePlugin to true"