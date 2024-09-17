#!/bin/bash

# Run terraform output -json and assign the result to a variable
TF_OUTPUT=$(terraform output -json)

# Parse the JSON values and set the environment variables
export TF_VAR_tenant_id=$(echo $TF_OUTPUT | jq -r '.tenant_id.value')
export TF_VAR_client_id=$(echo $TF_OUTPUT | jq -r '.client_id.value')
export TF_VAR_client_secret=$(echo $TF_OUTPUT | jq -r '.client_secret.value')
export TF_VAR_subscription_id=$(echo $TF_OUTPUT | jq -r '.subscription_id.value')

# Verify that the environment variables have been set
echo "TF_VAR_tenant_id is set to $TF_VAR_tenant_id"
echo "TF_VAR_client_id is set to $TF_VAR_client_id"
echo "TF_VAR_client_secret is set to [hidden for security]"
echo "TF_VAR_subscription_id is set to $TF_VAR_subscription_id"
