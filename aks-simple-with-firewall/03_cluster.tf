resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.aks_rg.location}"
  resource_group_name = "${azurerm_resource_group.aks_rg.name}"
  dns_prefix          = "${var.dns_prefix}"
  kubernetes_version  = "${var.k8s_version}"
  
  network_profile {
    network_plugin = "kubenet"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip = "10.2.0.10"
    service_cidr = "10.2.0.0/24"
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "${var.ssh_public_key_data}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "Standard_DS2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id  = "${azurerm_subnet.aks_agent.id}"
  }

  service_principal {
    client_id     = "${var.sp_client_id}"
    client_secret = "${var.sp_client_secret}"
  }

  tags {
    Environment = "${var.environment_name}"
  }

}