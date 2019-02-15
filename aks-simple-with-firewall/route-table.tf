# TODO_ Replace with something that is not dependent on external programs, once we can get the route-table name otherwise
data "external" "aks_route_table" {
  program = ["bash", "${path.module}/route-table-get-name.sh"]

  query = {
    resource_group = "${azurerm_kubernetes_cluster.aks_cluster.node_resource_group}"
  }
}

data "azurerm_route_table" "aks_firewall_routes" {
  name = "${data.external.aks_route_table.result.name}"
}

resource "azurerm_route" "aks_firewall_route" {
  resource_group_name    = "${azurerm_kubernetes_cluster.aks_cluster.node_resource_group}"
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