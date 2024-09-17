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

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "azure_mount_path" {
  description = "value of vault_azure_secret_backend.azure.path"
  type        = string
}

variable "role_name" {
  description = "Name of the Vault role for Azure"
  type        = string
}