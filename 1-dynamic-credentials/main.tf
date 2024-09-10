module "tier-1-azure-ad" {
  source        = "../modules/1-vault-azure-secrets-engine"
  vault_address = "http://127.0.0.1:8200"
  vault_token   = var.vault_token
  vault_namespace = "platform-team" # This should use data from the other module

  tenant_id          = var.tenant_id
  client_id          = var.client_id
  client_secret      = var.client_secret
  subscription_id    = var.subscription_id
  role_ttl           = "30d"
}
