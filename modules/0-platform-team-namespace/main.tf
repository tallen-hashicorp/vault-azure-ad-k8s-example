provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

resource "vault_namespace" "namespace" {
  path = var.namespace_name
}

resource "vault_identity_oidc" "server" {
  
}

resource "vault_identity_oidc_client" "test" {
  name          = "azure"
  id_token_ttl     = 2400
  access_token_ttl = 7200
}