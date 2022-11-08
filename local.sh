#!/bin/sh
PLUGIN_PATH="$HOME/.terraform.d/plugins/local/hashicorp/"
mkdir -p $PLUGIN_PATH
cp -rf ./vsphere $PLUGIN_PATH
