#!/bin/bash
# Post-Terraform script to grant admin consent for Azure AD app

APPLICATION_CLIENT_ID=$(terraform output -raw azure_app_id)

# Grant admin consent
az ad app permission admin-consent --id $APPLICATION_CLIENT_ID

echo "Admin consent granted for application ID $APPLICATION_CLIENT_ID"