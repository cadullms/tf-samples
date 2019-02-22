# See hint in https://www.terraform.io/docs/providers/azurerm/r/subnet_route_table_association.html
# We currently need to do both: Set the id property in the subnet and do this
# resource. Otherwise we will get problems on applying this a second time.
# Terraform will then try to set route_table_id and nsg_id from the correct value to "",
# because we did not specify them.
# Yet that is causing circular dependencies in our configuration:
# * For the subnet to be able to set the id, the route-table must exist
# * The route-table in simple networking model is created during cluster creation
# * Thus the cluster would need to be created before the subnet
# * Yet for cluster creation the subnet already needs to be in place 
# The last two requirements are a contradiction, so what can we do?

data "external" "aks_node_resource_group_info" {
  program = ["bash", "${path.module}/support-files/route-table-get-info.sh"]

  query = {
    aks_resource_group = "${var.resource_group_name}"
    aks_name           = "${azurerm_kubernetes_cluster.aks_cluster.name}"
    # This is dependent on the cluster, will thus be evaluated AFTER cluster creation
  }
}

data "external" "aks_node_resource_group_info_empty" {
  program = ["bash", "${path.module}/support-files/route-table-get-info.sh"]
   query = {
    aks_resource_group = "${var.resource_group_name}"
    aks_name           = "${var.cluster_name}"
    # This is NOT dependent on the cluster, will thus be evaluated BEFORE cluster creation.
    # Thus we can use it for the info we need to set on subnet creation.
    # The script will be resilient to this, and if the cluster does not exist yet,
    # will return empty strings, which are fine for the start. On subsequent 
    # runs the script will get the correct ids, so that it does not break things.
  }
} 

resource "azurerm_subnet" "aks_agent" {
  name                      = "aks-agent-subnet"
  resource_group_name       = "${azurerm_resource_group.aks_rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.aks_vnet.name}"
  address_prefix            = "10.0.5.0/24"
  network_security_group_id = "${lookup(data.external.aks_node_resource_group_info_empty.result,"nsg_id")}"  
  route_table_id            = "${lookup(data.external.aks_node_resource_group_info_empty.result,"rt_id")}"  
  service_endpoints         = ["Microsoft.Sql","Microsoft.AzureCosmosDB","Microsoft.KeyVault","Microsoft.Storage"]
}

resource "azurerm_subnet_route_table_association" "aks_agent_subnet_to_rt" {
  subnet_id      = "${azurerm_subnet.aks_agent.id}"
  route_table_id = "${lookup(data.external.aks_node_resource_group_info.result,"rt_id")}"
}

resource "azurerm_subnet_network_security_group_association" "aks_agent_subnet_to_nsg" {
  subnet_id      = "${azurerm_subnet.aks_agent.id}"
  network_security_group_id = "${lookup(data.external.aks_node_resource_group_info.result,"nsg_id")}"
}

resource "azurerm_route" "aks_agent_subnet_to_firewall" {
  name                   = "agents-to-fw-rule"
  resource_group_name    = "${azurerm_kubernetes_cluster.aks_cluster.node_resource_group}"
  route_table_name       = "${lookup(data.external.aks_node_resource_group_info.result,"rt_name")}"
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  # Following line would be better, but tf cannot find private_ip_address though doc says it should be there: https://www.terraform.io/docs/providers/azurerm/r/firewall.html#private_ip_address
  # next_hop_in_ip_address = "${azurerm_firewall.aks_firewall.ip_configuration.private_ip_address}"
  next_hop_in_ip_address = "10.0.3.4"
}