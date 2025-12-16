resource "azurerm_key_vault" "kv" {
  name                        = var.kv_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  sku_name                    = "standard"
  soft_delete_enabled         = true
  purge_protection_enabled    = true
}

resource "azurerm_key_vault_secret" "db_username" {
  name         = "database-username"
  value        = var.db_username
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "database-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_host" {
  name         = "database-host"
  value        = var.db_host
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_role_assignment" "aks_kv_reader" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.aks_managed_identity
}
