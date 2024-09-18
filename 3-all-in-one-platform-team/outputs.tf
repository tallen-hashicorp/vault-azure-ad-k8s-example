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

# Example: plugin-identity:jHmOm:secret:azure_38b36e27
output "azure_subject_identifier" {
  value = "plugin-identity:${module.vault-namespace.namespace_int_id}:secret:${module.tier-1-azure-ad.azure_mount_id}"
}