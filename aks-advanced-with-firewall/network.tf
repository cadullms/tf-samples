resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.aks_rg.location}"
  resource_group_name = "${azurerm_resource_group.aks_rg.name}"
}

resource "azurerm_subnet" "aks_firewall" {
  name                 = "aks-firewall-subnet"
  resource_group_name  = "${azurerm_resource_group.aks_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.aks_vnet.name}}]"
  address_prefix       = "10.0.3.0/24"
}

resource "azurerm_subnet" "aks_ingress" {
  name                 = "aks-ingress-subnet"
  resource_group_name  = "${azurerm_resource_group.aks_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.aks_vnet.name}}]"
  address_prefix       = "10.0.4.0/24"
}

resource "azurerm_subnet" "aks_agent" {
  name                 = "aks-agent-subnet"
  resource_group_name  = "${azurerm_resource_group.aks_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.aks_vnet.name}}]"
  address_prefix       = "10.0.5.0/24"
  # ???
  # az network vnet subnet list-available-delegations --location westeurope --query [].serviceName
  # delegation {
  #   name = "default-aks-delegations-sql"
  #   service_delegation {
  #     name    = "Microsoft.Sql/servers"
  #   }
  # }
  # delegation {
  #   name = "default-aks-delegations-sql"
  #   service_delegation {
  #     name    = "Microsoft.AzureCosmosDB"
  #   }
  # }
  # delegation {
  #   name = "default-aks-delegations-sql"
  #     service_delegation {
  #     name    = "Microsoft.KeyVault"
  #   }
  # }
  # delegation {
  #   name = "default-aks-delegations-sql"
  #     service_delegation {
  #     name    = "Microsoft.Storage"
  #   }
  # }
}

# This would be great, but it's not there yet
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/1338
# data "azurerm_service_principal" "aks_sp" {
#     client_id = "${var.sp_object_id}"
# }
# and then read ${azurerm_service_principal.aks_sp.object_id}. Then we would not neet to pass this as a parameter

resource "azurerm_role_assignment" "vnet-to-aks-sp" {
  scope              = "${azurerm_virtual_network.aks_vnet.id}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id       = "${var.sp_object_id}"
}