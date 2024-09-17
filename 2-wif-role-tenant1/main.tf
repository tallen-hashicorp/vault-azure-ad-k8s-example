module "tier-1-azure-ad" {
  source            = "../modules/2-vault-azure-secrets-role"
  vault_address     = var.vault_addr
  vault_token       = var.vault_token
  vault_namespace   = "platform-team" # This should use data from the other module

  role_name         = "tenant1"

  azure_mount_path  = "azure"

  azure_scope       = "/subscriptions/${var.subscription_id}"
}
