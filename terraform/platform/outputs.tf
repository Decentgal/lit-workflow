# These are the Platform layer's outputs
# These values are exported to the remote state file so the Application layer can read them dynamically. 

# Development Environment 

output "dev_resource_group_name" {
  description = "The name of the development resource group."
  value       = azurerm_resource_group.dev.name
}

output "dev_resource_group_id" {
  description = "The Azure Resource ID of the dev resource group (used for RBAC)."
  value       = azurerm_resource_group.dev.id
}

# Production Environment

output "prod_resource_group_name" {
  description = "The name of the production resource group."
  value       = azurerm_resource_group.prod.name
}

output "prod_resource_group_id" {
  description = "The Azure Resource ID of the prod resource group (used for RBAC)."
  value       = azurerm_resource_group.prod.id
}