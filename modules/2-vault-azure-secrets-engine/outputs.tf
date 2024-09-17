output "azure_mount_path" {
  description = "Value of vault_azure_secret_backend.azure.path"
  value = vault_azure_secret_backend.azure.path
}

output "azure_mount_id" {
  value = data.external.azure_accessor.result.accessor
}