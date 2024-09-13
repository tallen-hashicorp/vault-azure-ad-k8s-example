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
  subscription_id = var.subscription_id
  identity_token_audience = "api://AzureADTokenExchange"
}

resource "vault_identity_oidc" "server" {
  issuer = var.vault_address
}

resource "vault_identity_oidc_client" "oidc_client" {
  name          = "azure"
  id_token_ttl     = 2400
  access_token_ttl = 7200
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


