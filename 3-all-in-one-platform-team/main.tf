module "azure_setup" {
  source                = "../modules/0-azure-setup"
  location              = "West Europe"
  app_registration_name = "${var.app_name}-app"
  resource_group_names  = ["${var.app_name}-rg-1", "${var.app_name}-rg-2"]
  subscription_id       = var.subscription_id
}

module "vault-namespace" {
  source        = "../modules/0-platform-team-namespace"
  vault_address = var.vault_addr
  vault_token   = var.vault_token
  namespace_name = var.app_name
}

module "tier-1-azure-ad" {
  source        = "../modules/2-vault-azure-secrets-engine"
  vault_address = var.vault_addr
  vault_token   = var.vault_token
  vault_namespace = var.app_name

  role_name = "platform-team"

  tenant_id                 = module.azure_setup.tenant_id
  client_id                 = module.azure_setup.client_id
  subscription_id           = var.subscription_id
}

module "federated_credentials" {
  source            = "../modules/3-vault-wif-setup"
  subscription_id   = var.subscription_id
  
  application_id    = module.azure_setup.client_id


  display_name      = var.app_name
  issuer            = "${var.vault_addr}/v1/${var.app_name}/identity/oidc/plugins"
  subject           = "plugin-identity:${module.vault-namespace.namespace_int_id}:secret:${module.tier-1-azure-ad.azure_mount_id}"
  audiences         = [[replace("${var.vault_addr}/v1/${var.app_name}/identity/oidc/plugins", "https://", "")]] #<vault_url>:8200/v1/platform-team/identity/oidc/plugins
}

