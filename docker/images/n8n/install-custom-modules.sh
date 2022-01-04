#!/bin/bash

# create folder to install modules in
n8ndir="/home/node/.n8n"
if [ ! -d $home ] ; then
	mkdir $n8ndir
  chmod o+rx $n8ndir
  chown -R node $n8ndir
fi

if [ "$OPENSSH" = true ] ; then
  apk update && apk add openssh openssh-keygen expect
	mkdir /home/node/.ssh && chown node:node /home/node/.ssh && chmod 2700 /home/node/.ssh
fi

CUSTOM_MODULE_DIR="/home/node/.n8n/custom"
CUSTOM_FUNCTION_DIR="/usr/local/lib"

if [ ! -z "$CUSTOM_APK" ]
then
    LIST=(${CUSTOM_APK//;/ })
		apk update
    for module in "${LIST[@]}"; do
        echo "custom apk: ${module}"
        apk add ${module}
    done
		rm -rf /var/cache/apk/*
fi

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

# Install custom modules; --prefix does not work
if [ ! -z "$CUSTOM_MODULES" ]
then
    LIST=(${CUSTOM_MODULES//;/ })
		cd $CUSTOM_MODULE_DIR
    for module in "${LIST[@]}"; do
        echo "custom module: ${module}"
        npm i ${module}
    done
fi

# Install custom modules using --unsafe-perm flag; --prefix does not work
if [ ! -z "$CUSTOM_MODULES_UNSAFEPERM" ]
then
    LIST=(${CUSTOM_MODULES_UNSAFEPERM//;/ })
		cd $CUSTOM_MODULE_DIR
    for module in "${LIST[@]}"; do
        echo "custom module unsafeperm: ${module}"
        npm i ${module} --unsafe-perm
    done
fi

# Install allowed external functions; --prefix does not work
if [ ! -z "$NODE_FUNCTION_ALLOW_EXTERNAL" ]
then
    LIST=(${NODE_FUNCTION_ALLOW_EXTERNAL//,/ })
		cd $CUSTOM_FUNCTION_DIR
    for module in "${LIST[@]}"; do
        echo "custom external function: ${module}"
        npm i ${module}
    done
fi
