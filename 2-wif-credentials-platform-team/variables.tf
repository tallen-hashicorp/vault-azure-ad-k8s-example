variable "vault_token" {
  description = "The Vault token with appropriate permissions"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "identity_token_audience" {
  description = "Azure Identity Token Audience"
  type        = string
}

variable "vault_addr" {
  description = "The Vault Address"
  type        = string
  sensitive   = true
}