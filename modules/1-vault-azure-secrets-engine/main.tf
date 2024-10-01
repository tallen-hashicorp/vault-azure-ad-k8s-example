provider "vault" {
  address   = var.vault_address
  token     = var.vault_token
  namespace = var.vault_namespace
}

# Configure Azure Secrets Engine with authentication credentials
resource "vault_azure_secret_backend" "azure" {
  path            = var.azure_secrets_path
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
}

# Create an example Azure role for managing resource groups
resource "vault_azure_secret_backend_role" "resource_group_role" {
  backend = vault_azure_secret_backend.azure.path
  role    = var.role_name

  azure_roles {
    role_name = "Owner"
    scope =  "/subscriptions/${var.subscription_id}/*"
  }

  ttl = var.role_ttl
  max_ttl = var.max_role_ttl
}
