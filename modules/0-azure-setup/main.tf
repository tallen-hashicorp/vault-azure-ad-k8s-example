provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

# Data source to get the current subscription ID and tenant ID
data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "vault_platform_team" {}

# Define resource groups using dynamic for_each loop with toset conversion
resource "azurerm_resource_group" "vault_platform_team_rg" {
  for_each = toset(var.resource_group_names)
  name     = each.value
  location = var.location
}

# Create Azure App Registration
resource "azuread_application" "vault_platform_team_app" {
  display_name = var.app_registration_name

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    resource_access {
      id   = "18a4783c-866b-4cc7-a460-3d5e5662c884" # Application.ReadWrite.OwnedBy
      type = "Role"
    }
    resource_access {
      id   = "19dbc75e-c2e2-444c-a770-ec69d8559fc7" # Directory.ReadWrite.All
      type = "Role"
    }
    resource_access {
      id   = "c529cfca-c91b-489c-af2b-d92990b66ce6" # User.ManageIdentities.All
      type = "Role"
    }
  }
  
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000" # Azure Active Directory Graph
    resource_access {
      id   = "824c81eb-e3f8-4ee6-8f6d-de7f50d565b7" # Application.ReadWrite.OwnedBy
      type = "Role"
    }
    resource_access {
      id   = "1138cb37-bd11-4084-a2b7-9f71582aeddb" # Device.ReadWrite.All
      type = "Role"
    }
    resource_access {
      id   = "78c8a3c8-a07e-4b9e-af1b-b5ccab50a175" # Directory.ReadWrite.All
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "vault_platform_team_sp" {
  client_id = azuread_application.vault_platform_team_app.client_id
}

# Create a client secret (Service Principal Password)
resource "azuread_service_principal_password" "vault_platform_team_sp_password" {
  service_principal_id = azuread_service_principal.vault_platform_team_sp.id
  end_date_relative    = "8760h" # 1 year validity, adjust as needed
}

# Assign Owner role to the App Registration for full access to subscription
resource "azurerm_role_assignment" "vault_platform_team_role_assignment_owner" {
  principal_id         = azuread_service_principal.vault_platform_team_sp.id
  role_definition_name = "Owner"
  scope                = data.azurerm_subscription.primary.id
}

# Assign User Access Administrator role to allow the SP to assign roles
resource "azurerm_role_assignment" "vault_platform_team_role_assignment_uaa" {
  principal_id         = azuread_service_principal.vault_platform_team_sp.id
  role_definition_name = "User Access Administrator"
  scope                = data.azurerm_subscription.primary.id
}
