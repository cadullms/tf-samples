provider "azurerm" {
  version = "1.22.0"
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "aks_rg" {
  name     = "${local.resource_group_name}"
  location = "${var.location}"
}