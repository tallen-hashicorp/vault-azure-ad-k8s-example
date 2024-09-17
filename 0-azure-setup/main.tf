module "vault_platform_team" {
  source                = "../modules/0-azure-setup"
  location              = "West Europe"
  app_registration_name = "vault-platform-team-app"
  resource_group_names  = ["vault-platform-team-rg-1", "vault-platform-team-rg-2"]
  subscription_id       = var.subscription_id
}