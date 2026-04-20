# Decoupled architecture will never share or overwrite each other's state file.
# This is the Platform layer's own separate state file.

terraform {
  backend "azurerm" {
    resource_group_name  = "wogo-tfstate-rg"
    storage_account_name = "wogotfstate"
    container_name       = "tfstate"
    key                  = "platform.terraform.tfstate" 
  }
}