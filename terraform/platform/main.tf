# This is the PLATFORM/INFRASTRUCTURE layer owned and managed by WOGO cloud security engineers.
# It defines governance, policy, and the foundational resource groups.
# Application team/Software Developers cannot touch this layer.

data "azurerm_client_config" "current" {}

# Resource Groups - Separation of Duties
# The platform engineers creates the resource groups.
# The application developers deploys into the RG, they do/can not create or destroy them.

resource "azurerm_resource_group" "dev" {
  name     = "wogo-${var.environment}-rg"
  location = var.location

  tags = {
    environment  = var.environment
    managed_by   = "platform-terraform"
    owner        = "cloud-security-team"
  }
}

resource "azurerm_resource_group" "prod" {
  name     = "wogo-prod-rg"
  location = var.location

  tags = {
    environment  = "production"
    managed_by   = "platform-terraform"
    owner        = "cloud-security-team"
  }
}

# Note: The Azure Policy deny guardrail for PostgreSQL was restricted because of the Azure account type (Student). So, I removed the 3 blocks.

# In a production enterprise subscription, this policy would be applied as written, blocking PostgreSQL resource creation at the cloud control plane level.