locals {
  rg_name="${var.name}-rg"
  cluster_name="${var.name}-cluster"
  dns_prefix="${var.name}"
  aks_server_app_name="${var.name}-server-app"
  aks_client_app_name="${var.name}-client-app"
  aks_sp_name="${var.name}-sp"
}
