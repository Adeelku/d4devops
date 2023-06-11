terraform {
  # backend "local" {}
  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "tfstate378536530klh"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    subscription_id      = "c864a212-7331-4c54-a0e5-9573f830748a"
  }
}
