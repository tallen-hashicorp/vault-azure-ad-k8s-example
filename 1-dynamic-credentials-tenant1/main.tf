provider "vault" {
  address   = "http://127.0.0.1:8200"
  token     = var.vault_token #This should use a auth mount with a policy not root like we are using here
  namespace = "platform-team-1"
}

data "vault_generic_secret" "platform-team" {
  path = "azure/creds/platform-team"
}

module "vault-namespace" {
  source        = "../modules/0-platform-team-namespace"
  vault_address = "http://127.0.0.1:8200"
  vault_token   = var.vault_token
  namespace_name = "tenant1"
}

module "tier-1-azure-ad" {
  source        = "../modules/1-vault-azure-secrets-engine"
  vault_address = "http://127.0.0.1:8200"
  vault_token   = var.vault_token
  vault_namespace = module.vault-namespace.namespace_id # This should use data from the other module

  role_name = "tenant1"

  subscription_id    = var.subscription_id
  tenant_id          = var.tenant_id
  client_id          = data.vault_generic_secret.platform-team.data.client_id
  client_secret      = data.vault_generic_secret.platform-team.data.client_secret
  role_ttl           = 2592000 # 30 days
  max_role_ttl       = 2592000
}
