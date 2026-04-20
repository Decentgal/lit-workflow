# This is the second half of the decoupled architecture. 
# This APPLICATION layer is owned and managed by the development team. They create the App Service, ACR, and Key Vault.

# Dynamically fetches your Tenant ID without needing variables.
data "azurerm_client_config" "current" {}

# Generates a random number to ensure globally unique names.
resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

# Azure Container Registry 
resource "azurerm_container_registry" "acr" {
  name                = "wogoacr${random_integer.suffix.result}"
  resource_group_name = data.terraform_remote_state.platform.outputs.dev_resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = {
    environment = var.environment
    managed_by  = "application-terraform"
  }
}

# App Service Plan 
resource "azurerm_service_plan" "main" {
  name                = "wogo-asp"
  resource_group_name = data.terraform_remote_state.platform.outputs.dev_resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"

  tags = {
    environment = var.environment
    managed_by  = "application-terraform"
  }
}

# App Service: Dev 
resource "azurerm_linux_web_app" "dev" {
  name                = "wogo-dev-app-${random_integer.suffix.result}"
  resource_group_name = data.terraform_remote_state.platform.outputs.dev_resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on         = false
    health_check_path = "/api/v1/health"

    application_stack {
      docker_image_name   = "${azurerm_container_registry.acr.login_server}/wogo:dev-latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
  }

  app_settings = {
    "WEBSITES_PORT"              = "8000"
    "ENVIRONMENT"                = "development"
    "DOCKER_REGISTRY_SERVER_URL" = "https://${azurerm_container_registry.acr.login_server}"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  }
}

# App Service: Prod 
resource "azurerm_linux_web_app" "prod" {
  name                = "wogo-prod-app-${random_integer.suffix.result}"
  resource_group_name = data.terraform_remote_state.platform.outputs.prod_resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on         = true
    health_check_path = "/api/v1/health"

    application_stack {
      docker_image_name   = "${azurerm_container_registry.acr.login_server}/wogo:latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
  }

  app_settings = {
    "WEBSITES_PORT"              = "8000"
    "ENVIRONMENT"                = "production"
    "DOCKER_REGISTRY_SERVER_URL" = "https://${azurerm_container_registry.acr.login_server}"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  }
}

# The Azure student account cannot write role (ACRpull) assignments via the SP.
# Remove the two ACRPull blocks permanently and manually assign it.

# Key Vault 
resource "azurerm_key_vault" "main" {
  name                       = "wogo-kv-${random_integer.suffix.result}"
  resource_group_name        = data.terraform_remote_state.platform.outputs.dev_resource_group_name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id  
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
}

# MONITORING & OBSERVABILITY TOOLS
# Log Analytics Workspace
# This is the backend storage for all logs and metrics.
# Application Insights sends data here.

resource "azurerm_log_analytics_workspace" "main" {
  name                = "wogo-law"
  resource_group_name = data.terraform_remote_state.platform.outputs.dev_resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30         

  tags = {
    managed_by = "application-terraform"
  }
}

# Application Insights 
# This gives a ive visual dashboard of WOGO FastAPI app and tracks every request, response time, failure, and exception.

resource "azurerm_application_insights" "main" {
  name                = "wogo-appinsights"
  resource_group_name = data.terraform_remote_state.platform.outputs.dev_resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = {
    managed_by = "application-terraform"
  }
}

# Connect App Insights to both App Services
# Add the instrumentation key to both App Services as an environment variable.
# FastAPI automatically starts sending telemetry when this key is present.