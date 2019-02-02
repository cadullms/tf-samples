variable "agent_count" {
    default = 3
}

variable "cluster_name" {
}
variable "dns_prefix" {
    default = "${var.cluster_name}"
}