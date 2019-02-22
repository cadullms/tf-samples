resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.aks_rg.location}"
  resource_group_name = "${azurerm_resource_group.aks_rg.name}"
}

resource "azurerm_subnet" "AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = "${azurerm_resource_group.aks_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.aks_vnet.name}"
  address_prefix       = "10.0.3.0/24"
}

resource "azurerm_subnet" "aks_ingress" {
  name                 = "aks-ingress-subnet"
  resource_group_name  = "${azurerm_resource_group.aks_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.aks_vnet.name}"
  address_prefix       = "10.0.4.0/24"
}

#Agent Subnet is defined in agent_subnet_fix.tf

resource "azurerm_role_assignment" "vnet-to-aks-sp" {
  scope                = "${azurerm_virtual_network.aks_vnet.id}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = "${var.sp_object_id}"
}

