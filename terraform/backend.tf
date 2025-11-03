terraform {
  backend "azurerm" {
    resource_group_name   = "tfstate-rg"
    storage_account_name  = "tfstatek8s21718"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}
