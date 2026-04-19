# Just as Platform layer has its own state file, so does the Application layer's.
# Its state file is completely separate and cannot be tampered by the Platform layer, vice versa.

terraform {
  backend "azurerm" {
    resource_group_name  = "wogo-tfstate-rg"
    storage_account_name = "wogotfstate"
    container_name       = "tfstate"
    key                  = "application.terraform.tfstate"  
  }
}