resource "azurerm_postgresql_flexible_server" "pg" {
  name                = var.pg_name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.version
  delegated_subnet_id = var.subnet_id
  sku_name            = "Standard_D2s_v3"
  storage_mb          = 32768
  administrator_login          = var.admin_user
  administrator_login_password = var.admin_password

  high_availability {
    mode = "ZoneRedundant"
  }

  backup {
    geo_redundant_backup = "Enabled"
    retention_days       = 7
  }

  public_network_access_enabled = true
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "aks_rule" {
  name                = "allow-aks"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_flexible_server.pg.name
  start_ip_address    = var.aks_outbound_ip
  end_ip_address      = var.aks_outbound_ip
}

output "pg_fqdn" {
  value = azurerm_postgresql_flexible_server.pg.fqdn
}
