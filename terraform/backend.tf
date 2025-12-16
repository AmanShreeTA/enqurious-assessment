terraform {
  backend "azurerm" {
    resource_group_name  = "globalfinance-tfstate-rg"
    storage_account_name = "globalfinancestorage"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    lock_enabled         = true
  }
}
