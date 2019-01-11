output "private-ips" {
  value = "${azurerm_network_interface.myterraformnic.*.private_ip_address}"
}