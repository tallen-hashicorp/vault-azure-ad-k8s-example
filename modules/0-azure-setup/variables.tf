variable "location" {
  description = "Azure region where the resources will be created"
  type        = string
  default     = "West Europe"
}

variable "app_registration_name" {
  description = "Name of the Azure App Registration"
  type        = string
}

variable "resource_group_names" {
  description = "List of resource group names to create"
  type        = list(string)
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}