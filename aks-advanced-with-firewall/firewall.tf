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

#resource "azurerm_firewall_network_rule_collection" "aksnetwork" {
#  name                = "aksnetwork"
#  azure_firewall_name = "${azurerm_firewall.aks_firewall.name}"
#  resource_group_name = "${azurerm_resource_group.aks_rg.name}"
#  priority            = 100
#  action              = "Allow"
#
#  rule {
#    name = "allow network"
#
#    source_addresses = [
#      "*",
#    ]
#
#    destination_ports = [
#      "22",
#      "443",
#    ]
#
#    destination_addresses = [
#      "*",
#    ]
#
#    protocols = [
#      "TCP",
#    ]
#  }
#}

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
      "*cloudflare.docker.io",
      "*cloudflare.docker.com",
      "*registry-1.docker.io",
      "*ubuntu.com",
      "*azurecr.io",
      "*blob.core.windows.net",
      "*amazonaws.com",
    ]
  }
}
