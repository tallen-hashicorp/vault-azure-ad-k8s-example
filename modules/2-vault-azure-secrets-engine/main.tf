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

  # This is something like vault.the-tech-tutorial.com:8200/v1/platform-team/identity/oidc/plugins
  identity_token_audience = "${replace(var.vault_address, "https://", "")}/v1/${var.vault_namespace}/identity/oidc/plugins"
}

resource "vault_identity_oidc" "server" {
  issuer = var.vault_address
}

resource "vault_identity_oidc_client" "oidc_client" {
  name          = "azure"
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

data "external" "azure_accessor" {
  program = ["bash", "${path.module}/get_vault_accessor.sh"]

  # Pass necessary information to the script via the query
  query = {
    vault_addr  = var.vault_address
    vault_token = var.vault_token
    vault_namespace = var.vault_namespace  
    mount_path     = "${vault_azure_secret_backend.azure.path}"
  }

  # Ensure the external data depends on vault_azure_secret_backend being created
  depends_on = [vault_azure_secret_backend.azure]
}
