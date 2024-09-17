provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

# Data source to get the current subscription ID and tenant ID
data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "vault_platform_team" {}

# Define resource groups using dynamic for_each loop
resource "azurerm_resource_group" "resource_groups" {
  for_each = var.resource_group_names
  name     = each.value
  location = var.location
}

# Create Azure App Registration
resource "azuread_application" "vault_platform_team_app" {
  display_name = var.app_registration_name
}

resource "azuread_service_principal" "vault_platform_team_sp" {
  client_id = azuread_application.vault_platform_team_app.client_id
}

# Create a client secret (Service Principal Password)
resource "azuread_service_principal_password" "vault_platform_team_sp_password" {
  service_principal_id = azuread_service_principal.vault_platform_team_sp.id
  end_date_relative    = "8760h" # 1 year validity, adjust as needed
}

# Assign Contributor role to the App Registration for full access to subscription
resource "azurerm_role_assignment" "vault_platform_team_role_assignment" {
  principal_id         = azuread_service_principal.vault_platform_team_sp.id
  role_definition_name = "Owner"
  scope                = data.azurerm_subscription.primary.id
}
