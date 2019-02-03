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
  delegation {
    name = "default-aks-delegations"
    service_delegation {
      name    = "Microsoft.Sql/servers"
    }
    # ???
    # az network vnet subnet list-available-delegations --location westeurope --query [].serviceName
    service_delegation {
      name    = "Microsoft.AzureCosmosDB"
    }
    service_delegation {
      name    = "Microsoft.KeyVault"
    }
    service_delegation {
      name    = "Microsoft.Storage"
    }
  }
}

resource "azurerm_role_assignment" "vnet-to-aks-sp" {
  scope              = "${azurerm_virtual_network.aks_vnet.id}"
  role_definition_id = "Virtual Machine Contributor"
  principal_id       = "${var.sp_client_id}"
}