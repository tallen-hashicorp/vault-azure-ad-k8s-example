variable "vault_address" {
  description = "Vault address for provider configuration"
  type        = string
}

variable "vault_token" {
  description = "Vault token for provider authentication"
  type        = string
  sensitive   = true
}

variable "vault_namespace" {
  description = "Vault namespace for provider authentication"
  type        = string
}


variable "azure_secrets_path" {
  description = "Path where Azure Secrets Engine is enabled (default is 'azure/')"
  type        = string
  default     = "azure"
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "identity_token_audience" {
  description = "Azure Identity Token Audience"
  type        = string
}

variable "role_name" {
  description = "Name of the Vault role for Azure"
  type        = string
}