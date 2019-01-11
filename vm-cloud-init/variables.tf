variable "resource_group_name" {
  description = "The resource group for all this."
}                   

variable "location" {
  description = "The location for all this."
}                   

variable "cloudconfig_file" {
  default = "./cloudconfig.tpl"
  description = "The location of the cloud init configuration file."
}

variable "hello_world_text" {
  default = "world"
  description = "Will be written as part of a file in /tmp dir."
}

variable "count" {
  default = 1
  description = "How many VMs to create"
}

variable "admin_username" {
  default = "azureuser"
  description = "Name of the admin user for the VM. We have no password, the SSH key will be used to authenticate as this user."
}

variable "ssh_public_key_data" {
  description = "Value of the public key to be used for ssh access to the VM"
}