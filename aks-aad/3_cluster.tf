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

    # ssh_key {
    #   key_data = "${var.ssh_public_key_data}"
    # }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.node_count}"
    vm_size         = "Standard_DS2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${azuread_application.aks_sp.application_id}"
    client_secret = "${random_password.aks_sp.result}"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      client_app_id = "${azuread_application.aks_client_app.application_id}"
      server_app_id = "${azuread_application.aks_server_app.application_id}"
      server_app_secret = "${random_password.aks_server_app.result}"
    }
  }

}