module "vault-namespace" {
  source        = "../modules/0-platform-team-namespace"
  vault_address = var.vault_addr
  vault_token   = var.vault_token
}

module "namespace-setup" {
  source        = "../modules/0-platform-team-setup"
  vault_address = var.vault_addr
  vault_token   = var.vault_token
  vault_namespace = module.vault-namespace.namespace_id
  jwt_user_claim = "test"
  jwt_bound_audiences = ["test"]
}

module "tier-1-azure-ad" {
  source        = "../modules/2-vault-azure-secrets-engine"
  vault_address = var.vault_addr
  vault_token   = var.vault_token
  vault_namespace = "platform-team" # This should use data from the other module

  role_name = "platform-team"

  tenant_id                 = var.tenant_id
  client_id                 = var.client_id
  subscription_id           = var.subscription_id
}


output "namespace_id" {
  value = module.vault-namespace.namespace_id
}

output "namespace_int_id" {
  value = module.vault-namespace.namespace_int_id
}

output "azure_mount_id" {
  value = module.tier-1-azure-ad.azure_mount_id
}

output "azure_mount_path" {
  value = module.tier-1-azure-ad.azure_mount_path
}
