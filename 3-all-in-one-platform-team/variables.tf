variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "app_name" {
  description   = "Will be used for azure app and namespace naming"
  default       = "vault-platform-all-in-one-oct"
  type         = string
}

variable "vault_addr" {
  description = "The Vault Address"
  type        = string
  sensitive   = true
}

variable "vault_token" {
  description = "The Vault token with appropriate permissions"
  type        = string
  sensitive   = true
}