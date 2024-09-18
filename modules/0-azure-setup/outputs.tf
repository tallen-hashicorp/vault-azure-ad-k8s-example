output "client_id" {
  description = "The Client ID (Application ID) of the Azure App Registration"
  value       = azuread_application.vault_platform_team_app.client_id
}

output "object_id" {
  description = "The Object ID of the Azure App Registration"
  value       = azuread_application.vault_platform_team_app.object_id
}

output "client_secret" {
  description = "The Client Secret (password) for the Azure Service Principal"
  value       = azuread_service_principal_password.vault_platform_team_sp_password.value
}

output "subscription_id" {
  description = "The Subscription ID for the current Azure Subscription"
  value       = data.azurerm_subscription.primary.subscription_id
}

output "tenant_id" {
  description = "The Tenant ID for the current Azure Tenant"
  value       = data.azurerm_client_config.vault_platform_team.tenant_id
}
