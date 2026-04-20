# These are the Application layer's outputs.
# These values are printed to the terminal at the end of a successful apply.
# They provide the exact URLs and URIs needed to interact with the new systems.

# WOGO API Endpoints 

output "dev_app_url" {
  description = "The public URL for the Development App Service."
  value       = "https://${azurerm_linux_web_app.dev.default_hostname}"
}

output "prod_app_url" {
  description = "The public URL for the Production App Service."
  value       = "https://${azurerm_linux_web_app.prod.default_hostname}"
}

# Infrastructure URIs

output "container_registry_login_server" {
  description = "The URL of the Azure Container Registry (used by Docker push)."
  value       = azurerm_container_registry.acr.login_server
}

output "key_vault_uri" {
  description = "The URI of the Azure Key Vault (used by the Python app to fetch secrets)."
  value       = azurerm_key_vault.main.vault_uri
}

output "app_insights_name" {
  description = "Application Insights resource name — open this in Azure Portal for your dashboard"
  value       = azurerm_application_insights.main.name
}