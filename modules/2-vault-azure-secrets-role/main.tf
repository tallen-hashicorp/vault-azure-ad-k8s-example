provider "vault" {
  address   = var.vault_address
  token     = var.vault_token
  namespace = var.vault_namespace
}

# Create an example Azure role for managing resource groups
resource "vault_azure_secret_backend_role" "resource_group_role" {
  backend = vault_azure_secret_backend.azure.path
  role    = var.role_name

  azure_roles {
    role_name = "Owner"
    scope =  "/subscriptions/${var.subscription_id}"
  }
}


