terraform {
  backend "azurerm" {
    # You can either remove this backend (and use local state) or need to have storage 
    # account ready for remote state and specify storage_account_name, container_name, key 
    # and a secret for this using partial configuration.
    # See:
    # https://www.terraform.io/docs/backends/types/azurerm.html
    # https://www.terraform.io/docs/backends/config.html#partial-configuration
  }
}