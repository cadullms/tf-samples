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

resource "azurerm_subnet" "aks_agent" {
  name                 = "aks-agent-subnet"
  resource_group_name  = "${azurerm_resource_group.aks_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.aks_vnet.name}"
  address_prefix       = "10.0.5.0/24"
  service_endpoints    = ["Microsoft.Sql","Microsoft.AzureCosmosDB","Microsoft.KeyVault","Microsoft.Storage"]
}

resource "azurerm_role_assignment" "vnet-to-aks-sp" {
  scope                = "${azurerm_virtual_network.aks_vnet.id}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = "${var.sp_object_id}"
}

resource "azurerm_public_ip" "aks_firewall_ip" {
  name                = "aks-firewall-ip"
  location            = "${azurerm_resource_group.aks_rg.location}"
  resource_group_name = "${azurerm_resource_group.aks_rg.name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

data "azurerm_route_table" "aks_firewall_routes" {
  resource_group_name = "${azurerm_kubernetes_cluster.advanced_with_firewall.node_resource_group}"
  name                = "blah"
}

resource "azurerm_route" "aks_firewall_route" {
  resource_group_name    = "${azurerm_kubernetes_cluster.advanced_with_firewall.node_resource_group}"
  route_table_name       = "${data.azurerm_route_table.aks_firewall_routes.name}"
  name                   = "aks-firewall-route"
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.3.4"
}

resource "azurerm_subnet_route_table_association" "aks_agent_route_table_association" {
  subnet_id      = "${azurerm_subnet.aks_agent.id}"
  route_table_id = "${data.azurerm_route_table.aks_firewall_routes.id}"
}