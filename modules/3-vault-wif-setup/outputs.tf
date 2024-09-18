output "federated_credential_id" {
  description = "The ID of the federated credential."
  value       = azuread_application_federated_identity_credential.federated_credential.id
}