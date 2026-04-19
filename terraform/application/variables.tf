variable "subscription_id" {
  description = "Azure Subscription ID — injected by pipeline via OIDC"
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
  description = "Deployment environment. Guards against dev settings reaching prod."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be 'dev' or 'prod' only."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "southafricanorth"
}