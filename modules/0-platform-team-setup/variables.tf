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

variable "jwt_bound_audiences" {
  description = "The expected 'aud' claim in JWTs, used to validate the token's audience"
  type        = list(string)
}

variable "jwt_user_claim" {
  description = "The claim in the JWT that identifies the user, typically 'sub' or 'email'"
  type        = string
}