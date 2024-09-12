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