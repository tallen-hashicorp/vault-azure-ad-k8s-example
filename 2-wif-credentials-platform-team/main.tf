module "tier-1-azure-ad" {
  source        = "../modules/2-vault-azure-secrets-engine"
  vault_address = var.vault_addr
  vault_token   = var.vault_token
  vault_namespace = "admin/platform-team/" # This should use data from the other module

  role_name = "platform-team"

  tenant_id                 = var.tenant_id
  client_id                 = var.client_id
  subscription_id           = var.subscription_id
  identity_token_audience   = "${var.vault_addr}/v1/identity/oidc"
}
