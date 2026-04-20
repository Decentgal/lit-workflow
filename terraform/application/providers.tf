terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# OIDC Authentication 
# Azure Pipelines handles the OIDC token invisibly via environment variables.
provider "azurerm" {
  features {
    key_vault {
      # The App team manages the Key Vault, so this guardrail lives here.
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  use_oidc        = true   # Zero-Trust Authentication to the remote state.
}

# This is the bridge between the two layered architecture.
# This layer reads the platform state file to get the already created RG's names, it does not create them.

data "terraform_remote_state" "platform" {
  backend = "azurerm"

  config = {
    resource_group_name  = "wogo-tfstate-rg"
    storage_account_name = "wogotfstate"
    container_name       = "tfstate"
    key                  = "platform.terraform.tfstate"
  }
}