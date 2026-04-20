terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

# OIDC Authentication
# Azure Pipelines proves its identity to Azure using Identity Federation.
# It passes ARM_CLIENT_ID, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID, and ARM_USE_OIDC=true as environment variables behind the scenes.
provider "azurerm" {
  features {}
  
  # The Subscription ID is only what is explicitly provided while the pipeline's environment variables handle the rest invisibly.
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  use_oidc        = true    # Zero-Trust Authentication to the remote state.
}