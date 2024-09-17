provider "vault" {
  address   = var.vault_address
  token     = var.vault_token
  namespace = var.vault_namespace
}

# Create an example Azure role for managing resource groups
resource "vault_azure_secret_backend_role" "resource_group_role" {
  backend = var.azure_mount_path
  role    = var.role_name

  azure_roles {
    role_name = "Owner"
    scope =  var.azure_scope
  }
}


