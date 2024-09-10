# Vault provider configuration
provider "vault" {
  address               = var.vault_address
  token                 = var.vault_token
  namespace             = var.vault_namespace
}

# Create the policy with full control over the platform team namespace
resource "vault_policy" "platform_team_admin_policy" {
  name                  = "platform-team-admin-policy"
  policy                = <<EOT
# Full access to the platform team's own namespace
path "platform-team/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Allow creation of new namespaces
path "sys/namespaces/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Full access to any newly created namespaces under platform team's namespace
path "platform-team/namespace/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}


# Enable the userpass authentication method if not already enabled
resource "vault_auth_backend" "userpass" {
  type                  = "userpass"
  description           = "Userpass authentication for platform team"
}


# Enable JWT authentication if not already enabled
resource "vault_auth_backend" "jwt" {
  type                  = "jwt"
  description           = "JWT authentication for platform team"
}