variable "location" { default = "East US" }
variable "resource_group_name" { default = "globalfinance-prod-rg" }

module "acr" {
  source              = "../../modules/acr"
  acr_name            = "globalfinanceacraman"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "aks" {
  source              = "../../modules/aks"
  aks_name            = "globalfinance-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  node_count          = 2
  node_size           = "Standard_D2s_v3"
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.aks_managed_identity
}

module "postgres" {
  source              = "../../modules/postgresql"
  pg_name             = "globalfinance-pg"
  location            = var.location
  resource_group_name = var.resource_group_name
  admin_user          = "postgres"
  admin_password      = "SecureP@ss123"
  subnet_id           = "<subnet_id_here>"
  aks_outbound_ip     = "<aks_outbound_ip_here>"
}

module "keyvault" {
  source                = "../../modules/keyvault"
  kv_name               = "globalfinance-kv-prod123"
  location              = var.location
  resource_group_name   = var.resource_group_name
  db_username           = module.postgres.admin_user
  db_password           = module.postgres.admin_password
  db_host               = module.postgres.pg_fqdn
  aks_managed_identity  = module.aks.aks_cluster_name
}

output "aks_managed_identity" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "acr_id" {
  value = azurerm_container_registry.acr.id
}