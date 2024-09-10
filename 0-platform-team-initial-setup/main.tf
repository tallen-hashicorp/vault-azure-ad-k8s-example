module "vault-namespace" {
  source        = "../modules/0-platform-team-namespace"
  vault_address = "http://127.0.0.1:8200"
  vault_token   = var.vault_token
}

module "namespace-setup" {
  source        = "../modules/0-platform-team-setup"
  vault_address = "http://127.0.0.1:8200"
  vault_token   = var.vault_token
  vault_namespace = module.vault-namespace.namespace_id
  jwt_user_claim = "test"
  jwt_bound_audiences = ["test"]
}