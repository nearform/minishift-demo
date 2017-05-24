#!/bin/bash

set -eo pipefail

latest_release () {
  declare url=$1
  curl -L -s -H 'Accept: application/json' "$url" | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/'  
}

extract () {
  declare file=$1 dir=$2
  mkdir -p "$dir" && tar -xzf "$file" -C "$dir"
}

OS_TYPE=$(uname -s)

echo "(1/5) Installing minishift..."
LATEST_RELEASE=$(latest_release https://github.com/minishift/minishift/releases/latest)
FILE=minishift.tgz
DIR=./minishift

curl -sL https://github.com/minishift/minishift/releases/download/"${LATEST_RELEASE}"/minishift-"${LATEST_RELEASE:1}"-"${OS_TYPE}"-amd64.tgz -o $FILE
extract $FILE $DIR

echo "(2/5) Where do you want to copy the executable? (default: /usr/local/bin)"
read -r MINISHIFT_PATH

if [[ -z $MINISHIFT_PATH ]]; then
  MINISHIFT_PATH=/usr/local/bin
fi

cp $DIR/minishift $MINISHIFT_PATH
rm -rf $FILE $DIR

echo "(3/5) Which hypervisor do you want to use? (recommended: virtualbox)?"
[[ "$OS_TYPE" == "Darwin" ]] && echo "(xhyve, virtualbox, vmware-fusion)" || echo "(kvm, virtualbox)"
read -r HYPERVISOR

if [[ -z $HYPERVISOR ]]; then
  HYPERVISOR=virtualbox
fi

echo "(4/5) set minishift config.  View config at ./minishift/config/config.json"
minishift config set vm-driver $HYPERVISOR

# adjust memory and cpus below
#minishift config set memory 4096
#minishift config set cpus 4

echo "(6/6) minishift start"
minishift start