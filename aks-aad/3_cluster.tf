resource "azurerm_resource_group" "aks_rg" {
  name     = "${local.rg_name}"
  location = "${var.location}"
}

resource "azurerm_kubernetes_cluster" "aks_with_aad" {
  name                = "${local.cluster_name}"
  location            = "${azurerm_resource_group.aks_rg.location}"
  resource_group_name = "${azurerm_resource_group.aks_rg.name}"
  dns_prefix          = "${local.dns_prefix}"

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = "${var.ssh_public_key_data}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.node_count}"
    vm_size         = "Standard_DS2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.sp_app_id}"
    client_secret = "${var.sp_app_secret}"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      client_app_id = "${var.aad_client_app_id}"
      server_app_id = "${var.aad_server_app_id}"
      server_app_secret = "${var.aad_server_app_secret}"
      tenant_id = "${var.aad_tenant_id}"
    }
  }
}