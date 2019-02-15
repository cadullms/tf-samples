#!/bin/bash

# See https://www.terraform.io/docs/providers/external/data_source.html

# Exit if any of the intermediate steps fail
set -e

eval "$(jq -r '@sh "RESOURCE_GROUP=\(.resource_group)"')"

# We assume that az is installed and these envs are set:
# $ARM_CLIENT_ID
# $ARM_CLIENT_SECRET
# $ARM_TENANT_ID

az aks login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID
$NAME = $(az network route-table list -g $RESOURCE_GROUP --query "[].name" -o tsv)

jq -n --arg foobaz "$NAME" '{"name":$name}'