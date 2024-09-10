variable "vault_address" {
  description = "The address of the Vault server"
  type        = string
}

variable "vault_token" {
  description = "The Vault token with appropriate permissions"
  type        = string
  sensitive   = true
}

variable "namespace_name" {
  description = "The Vault token with appropriate permissions"
  default = "platform-team"
  type        = string
}