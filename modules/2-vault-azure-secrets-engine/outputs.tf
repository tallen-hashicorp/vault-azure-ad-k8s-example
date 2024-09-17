output "azure_mount_path" {
  description = "Value of vault_azure_secret_backend.azure.path"
  value = vault_azure_secret_backend.azure.path
}

output "azure_mount_id" {
  value = data.external.azure_accessor.result.accessor
}

# Example: plugin-identity:jHmOm:secret:azure_38b36e27
output "azure_subject_identifier" {
  value = "plugin-identity:${vault_azure_secret_backend.azure.path}:secret:${data.external.azure_accessor.result.accessor}"
}