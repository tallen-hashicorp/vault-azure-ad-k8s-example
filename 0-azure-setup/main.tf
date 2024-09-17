module "vault_platform_team" {
  source                = "../modules/0-azure-setup"
  location              = "West Europe"
  app_registration_name = "vault-platform-team-app"
  resource_group_names  = ["vault-platform-team-rg-1", "vault-platform-team-rg-2"]
  subscription_id       = var.subscription_id
}

# Outputs from the module
output "client_id" {
  description = "The Client ID (Application ID) of the Azure App Registration"
  value       = module.vault_platform_team.client_id
}

output "client_secret" {
  description = "The Client Secret (password) for the Azure Service Principal"
  value       = module.vault_platform_team.client_secret
  sensitive   = true
}

output "subscription_id" {
  description = "The Subscription ID for the current Azure Subscription"
  value       = module.vault_platform_team.subscription_id
}

output "tenant_id" {
  description = "The Tenant ID for the current Azure Tenant"
  value       = module.vault_platform_team.tenant_id
}