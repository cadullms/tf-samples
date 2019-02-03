output "kube_config" {
  value = "${azurerm_kubernetes_cluster.advanced_with_firewall.kube_config_raw}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.advanced_with_firewall.kube_config.0.host}"
}