variable "resource_group_name" {
  description = "The resource group for all this."
}                   

variable "location" {
  description = "The location for all this."
}                   

variable "init_script_file" {
  default = "./InitMachine.ps1.tpl"
  description = "The path of the init script to use."
}

variable "hello_world_text" {
  default = "world"
  description = "Text that Will be passed to the init-script as param."
}

variable "count" {
  default = 1
  description = "How many VMs to create"
}

variable "admin_username" {
  default = "azureuser"
  description = "Name of the admin user for the VM."
}

variable "admin_password" {
  description = "Admin Password for the VM."
}