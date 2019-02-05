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

resource "azurerm_subnet_route_table_association" "aks_agent_route_table_association" {
  subnet_id      = "${azurerm_subnet.aks_agent.id}"
  route_table_id = "${azurerm_route_table.aks_firewall_routes.id}"
}

# resource "azurerm_subnet_route_table_association" "aks_ingress_route_table_association" {
#   subnet_id      = "${azurerm_subnet.aks_ingress.id}"
#   route_table_id = "${azurerm_route_table.aks_firewall_routes.id}"
# }

# This would be great, but it's not there yet
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/1338
# data "azurerm_service_principal" "aks_sp" {
#     client_id = "${var.sp_object_id}"
# }
# and then read ${azurerm_service_principal.aks_sp.object_id}. Then we would not neet to pass this as a parameter

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

resource "azurerm_firewall" "aks_firewall" {
  name                = "aks-firewall"
  location            = "${azurerm_resource_group.aks_rg.location}"
  resource_group_name = "${azurerm_resource_group.aks_rg.name}"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = "${azurerm_subnet.AzureFirewallSubnet.id}"
    public_ip_address_id = "${azurerm_public_ip.aks_firewall_ip.id}"
  }
}

resource "azurerm_firewall_application_rule_collection" "essential-arm-firewall-rules" {
  name                = "aksbasics"
  azure_firewall_name = "${azurerm_firewall.aks_firewall.name}"
  resource_group_name = "${azurerm_resource_group.aks_rg.name}"
  priority            = 100
  action              = "Allow"

  rule {
    name = "allow network"
    source_addresses = [
      "*",
    ]

    protocol {
      type = "Http"
      port = 80
    }

    protocol {
      type = "Https"
      port = 443
    }

    target_fqdns = [
      "*azmk8s.io",
      "*auth.docker.io",
      "*cloudflare.docker.com",
      "*registry-1.docker.io",
      "*ubuntu.com",
      "*azurecr.io",
      "*blob.core.windows.net"
    ]
  }
}

resource "azurerm_route_table" "aks_firewall_routes" {
  name                          = "aks-firewall-routes"
  location                      = "${azurerm_resource_group.aks_rg.location}"
  resource_group_name           = "${azurerm_resource_group.aks_rg.name}"
  disable_bgp_route_propagation = false

  route {
    name                   = "aks-firewall-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.3.4"
  }

  tags {
    environment = "${var.environment_name}"
  }
}