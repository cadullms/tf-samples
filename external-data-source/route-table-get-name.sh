# #!/bin/bash

# # See https://www.terraform.io/docs/providers/external/data_source.html
# logfile="route-table-get-name.log"
# echo "Start external resource." > $logfile

# # Exit if any of the intermediate steps fail
# set -e

# eval "$(jq -r '@sh "RESOURCE_GROUP=\(.resource_group)"')"

# # We assume that az is installed and either logged in or these envs are set:
# # $ARM_CLIENT_ID
# # $ARM_CLIENT_SECRET
# # $ARM_TENANT_ID

# # TODO: Do login in case we are not logged in yet.
# # az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID

# name=$(az network route-table list -g $RESOURCE_GROUP --query "[].name" -o tsv)

# echo "ARM_CLIENT_ID: $ARM_CLIENT_ID" >> $logfile
# echo "ARM_TENANT_ID: $ARM_TENANT_ID" >> $logfile
# echo "RESOURCE_GROUP: $RESOURCE_GROUP" >> $logfile
# echo "name: $name" >> $logfile

# jq -n --arg name "$name" '{"name":$name}'