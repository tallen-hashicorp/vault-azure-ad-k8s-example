provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

resource "azuread_application_federated_identity_credential" "federated_credential" {
  application_id        = var.application_id
  display_name          = var.display_name
  issuer                = var.issuer   # Custom issuer
  subject               = var.subject  # Custom subject claim (depends on the token structure from the issuer)
  audiences             = var.audiences
  description           = var.description
}