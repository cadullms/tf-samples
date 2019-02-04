variable "resource_group_name" {
}

variable "location" {
  default = "westeurope"
}

variable "agent_count" {
  default = 3
}

variable "cluster_name" {
}

variable "k8s_version" {
  default = "1.12.4"
}

variable "dns_prefix" {
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

variable "environment_name" {
}