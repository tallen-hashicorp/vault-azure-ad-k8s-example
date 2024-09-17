variable "vault_token" {
  description = "The Vault token with appropriate permissions"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "vault_addr" {
  description = "The Vault Address"
  type        = string
}