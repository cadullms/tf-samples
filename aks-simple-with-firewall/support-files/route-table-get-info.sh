# This is only needed because we are setting the 

#!/bin/bash

# See https://www.terraform.io/docs/providers/external/data_source.html
logfile="route-table-get-info.log"
echo "Start external data resource." > $logfile

# Exit if any of the intermediate steps fail
set -e

eval "$(jq -r '@sh "AKS_RESOURCE_GROUP=\(.aks_resource_group)"')"
eval "$(jq -r '@sh "AKS_NAME=\(.aks_name)"')"

echo "AKS_RESOURCE_GROUP: $AKS_RESOURCE_GROUP" >> $logfile
echo "AKS_NAME          : $AKS_NAME" >> $logfile

# We assume that az is installed and we are logged in. 

# TODO: Do login in case we are not logged in yet. Then we assume that these envs are set:
# $ARM_CLIENT_ID
# $ARM_CLIENT_SECRET
# $ARM_TENANT_ID
# az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID

node_rg_name=$(az aks list -g $AKS_RESOURCE_GROUP --query "[?name=='$AKS_NAME'].nodeResourceGroup" --o tsv)
if [ -z "$node_rg_name" ]; then
    rt_name=""
    rt_id=""
    nsg_name=""
    nsg_id=""
else
    # TODO: Get json and use jq to extract the values. will be a bit quicker
    rt_name=$(az network route-table list -g $node_rg_name --query "[].name" -o tsv)
    rt_id=$(az network route-table list -g $node_rg_name --query "[].id" -o tsv)
    nsg_name=$(az network nsg list -g $node_rg_name --query "[].name" -o tsv)
    nsg_id=$(az network nsg list -g $node_rg_name --query "[].id" -o tsv)
fi

echo "rt_name  : $rt_name" >> $logfile
echo "rt_id    : $rt_id" >> $logfile
echo "nsg_name : $nsg_name" >> $logfile
echo "nsg_id   : $nsg_id" >> $logfile

jq -n \
  --arg rt_name "$rt_name"\
  --arg rt_id "$rt_id"\
  --arg nsg_name "$nsg_name"\
  --arg nsg_id "$nsg_id"\
   '{"rt_name":"$rt_name","rt_id":"$rt_id","nsg_name":"$nsg_name","nsg_id":"$nsg_id"}'