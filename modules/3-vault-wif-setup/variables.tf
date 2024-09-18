variable "location" {
  description = "Azure region where the resources will be created"
  type        = string
  default     = "West Europe"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "application_id" {
  description = "The Application ID of the Azure App Registration."
  type        = string
}

variable "display_name" {
  description = "A friendly name for the federated credential."
  type        = string
  default     = "Federated Credential"
}

variable "issuer" {
  description = "The identity provider issuing tokens (for example: https://token.actions.githubusercontent.com for GitHub Actions)."
  type        = string
}

variable "subject" {
  description = "The subject from the token that will be mapped (for example: repo:<org>/<repo>:ref:refs/heads/<branch> for GitHub Actions)."
  type        = string
}

variable "audiences" {
  description = "The audience to target. Must be an array. Example: ['api://AzureADTokenExchange']"
  type        = list(string)
  default     = ["api://AzureADTokenExchange"]
}

variable "description" {
  description = "A description of the federated credential."
  type        = string
  default     = "Federated identity credential for authentication."
}
