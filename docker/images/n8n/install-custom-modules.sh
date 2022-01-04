#!/bin/bash

if $OPENSSH; then
  apk update && apk add openssh openssh-keygen expect
	mkdir /home/node/.ssh && chown node:node /home/node/.ssh && chmod 2700 /home/node/.ssh
fi
# apk --virtual build-dependencies add python make g++ bash
CUSTOM_MODULE_DIR="/home/node/.n8n/custom"
CUSTOM_FUNCTION_DIR="/usr/local/lib"

# Create custom extension folder if it is not present
if [ ! -z "$N8N_CUSTOM_EXTENSIONS" ]
then
    LIST=(${N8N_CUSTOM_EXTENSIONS//;/ })
    if [[ ! -d "${LIST[0]}" ]]
    then
        echo "custom extension: ${LIST[0]}"
        mkdir "${LIST[0]}"
    fi
    CUSTOM_MODULE_DIR="${LIST[0]}"
else
    if [[ ! -d "$CUSTOM_MODULE_DIR" ]]
    then
        mkdir "$CUSTOM_MODULE_DIR"
    fi
fi

# Install custom modules
if [ ! -z "$CUSTOM_MODULES" ]
then
    LIST=(${CUSTOM_MODULES//;/ })
    for module in "${LIST[@]}"; do
        echo "custom module: ${module}"
        npm i --prefix $CUSTOM_MODULE_DIR ${module}
    done
fi

# Install custom modules using --unsafe-perm flag
if [ ! -z "$CUSTOM_MODULES_UNSAFEPERM" ]
then
    LIST=(${CUSTOM_MODULES_UNSAFEPERM//;/ })
    for module in "${LIST[@]}"; do
        echo "custom module unsafeperm: ${module}"
        npm i --prefix $CUSTOM_MODULE_DIR ${module} --unsafe-perm
    done
fi

# Install allowed external functions
if [ ! -z "$NODE_FUNCTION_ALLOW_EXTERNAL" ]
then
    LIST=(${NODE_FUNCTION_ALLOW_EXTERNAL//,/ })
    for module in "${LIST[@]}"; do
        echo "custom external function: ${module}"
        npm i --prefix $CUSTOM_FUNCTION_DIR ${module}
    done
fi

apk del build-dependencies
rm -rf /var/cache/apk/*
