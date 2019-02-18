# # TODO_ Replace with something that is not dependent on external programs, once we can get the route-table name otherwise
resource "null_resource" "cluster_route_table_finish" {

  provisioner  "local-exec" {
    command = "./support-files/cluster-route-table-finish.sh"
    environment {
      KUBE_RESOURCE_GROUP = "${var.resource_group_name}"
      NODE_RESOURCE_GROUP = "${azurerm_kubernetes_cluster.aks_cluster.node_resource_group}"
      AGENT_SUBNET_ID = "${azurerm_subnet.aks_agent.id}"
      # Following line would be better, but tf cannot find private_ip_address though doc says it should be there: https://www.terraform.io/docs/providers/azurerm/r/firewall.html#private_ip_address
      # FW_PRIVATE_IP = "${azurerm_firewall.aks_firewall.ip_configuration.private_ip_address}"
      FW_PRIVATE_IP = "10.0.3.4"
      SUBSCRIPTION_ID = "${data.azurerm_subscription.current.id}"
    }
  }

  depends_on = ["azurerm_firewall.aks_firewall"] #TODO: Remove, once the private ip works (see above), because then the dependency will be implicit
  
}