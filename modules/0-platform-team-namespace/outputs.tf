output "namespace_id" {
  description = "The ID of the created Vault namespace"
  value       = vault_namespace.namespace.id
}

output "namespace_path" {
  description = "The ID of the created Vault namespace"
  value       = vault_namespace.namespace.path_fq
}

output "namespace_int_id" {
  description = "The ID of the created Vault namespace"
  value       = vault_namespace.namespace.namespace_id
}