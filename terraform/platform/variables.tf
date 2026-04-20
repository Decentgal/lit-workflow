variable "subscription_id" {
  description = "Azure Subscription ID — injected by pipeline or local tfvars"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID — used for OIDC authentication"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Service Principal App ID — used for OIDC authentication"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment. Prevents dev settings reaching prod."
  type        = string

  # This validation is a strict guardrail, no one can accidentally type 'production' or 'staging' and deploy wrongly.
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'. No other value is accepted."
  }
}

variable "location" {
  description = "Azure region for all platform resources"
  type        = string
  default     = "southafricanorth"
}