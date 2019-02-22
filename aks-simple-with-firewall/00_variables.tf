variable "name" {
  
}

locals {
  resource_group_name = "${var.name}-rg"
  cluster_name        = "${var.name}"
}

variable "environment_name" {
}

variable "dns_prefix" {
}

variable "location" {
  default = "westeurope"
}

variable "agent_count" {
  default = 3
}

variable "k8s_version" {
  default = "1.12.4"
}

variable "ssh_public_key_data" {
}

variable "sp_object_id" {
  description="Not the app registration's object id needed here. It MUST be the (corresponding) service principal's object id. You can get that with: az ad sp list --show-mine --query \"[?displayName=='myappandspdisplayname']\""
}

variable "sp_client_id" {
}

variable "sp_client_secret" {
}

variable "jumphost_admin_username" {}
variable "jumphost_admin_ssh_public_key_data" {}
