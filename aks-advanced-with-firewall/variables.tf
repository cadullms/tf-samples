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
  description="Not the app registration's object id needed here. It MUST be the (corresponding) service principal's object id. You can get that with: az ad sp list --show-mine --query \"[?appId=='<sp_client_id>'].objectId\" where <sp_client_id> is the same value you specify here for the sp_client_id parameter. If that gives you no result, replace --show-mine with --all but be prepared for a longer wait..."
}

variable "sp_client_id" {
  description="The client id (or app id) of the service principal that your AKS cluster will use to authenticate against Azure."
}

variable "sp_client_secret" {
  description="The client secret of the service principal that your AKS cluster will use to authenticate against Azure."
}

variable "environment_name" {
}

variable "jumphost_admin_username" {}
variable "jumphost_admin_ssh_public_key_data" {}
