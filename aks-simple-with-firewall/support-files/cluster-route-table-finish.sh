#!/bin/bash

echo "Start cluster-route-table-finish..."
echo "KUBE_RESOURCE_GROUP: $KUBE_RESOURCE_GROUP"
echo "NODE_RESOURCE_GROUP: $NODE_RESOURCE_GROUP"
echo "AGENT_SUBNET_ID    : $AGENT_SUBNET_ID"
echo "FW_PRIVATE_IP      : $FW_PRIVATE_IP"
echo "SUBSCRIPTION_ID    : $SUBSCRIPTION_ID"

# Exit if any of the intermediate steps fail
set -e

# We assume that az is installed and logged in 

# TODO: Do login in case we are not logged in yet. Requires these envs are set:
# $ARM_CLIENT_ID
# $ARM_CLIENT_SECRET
# $ARM_TENANT_ID
# az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID

route_table_name=$(az network route-table list -g $NODE_RESOURCE_GROUP --query "[].name | [0]" -o tsv)
route_table_id=$(az network route-table list -g $NODE_RESOURCE_GROUP --query "[].id | [0]" -o tsv)
node_nsg_id=$(az network nsg list -g $NODE_RESOURCE_GROUP --query "[].id | [0]" -o tsv)

echo "route_table_name: $route_table_name" 
echo "route_table_id  : $route_table_id" 
echo "node_nsg_id     : $node_nsg_id"

az network vnet subnet update \
  --resource-group $KUBE_RESOURCE_GROUP \
  --route-table $route_table_id \
  --network-security-group $node_nsg_id \
  --ids $AGENT_SUBNET_ID
az network route-table route create \
  --resource-group $NODE_RESOURCE_GROUP \
  --name "agents-to-fw-rule" \
  --route-table-name $route_table_name \
  --address-prefix "0.0.0.0/0" \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address $FW_PRIVATE_IP \
  --subscription $SUBSCRIPTION_ID