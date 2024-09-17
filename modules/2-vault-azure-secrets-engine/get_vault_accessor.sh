#!/bin/bash

# Retrieve parameters from the query
eval "$(jq -r '@sh "VAULT_ADDR=\(.vault_addr) VAULT_TOKEN=\(.vault_token) VAULT_NAMESPACE=\(.vault_namespace) MOUNT_PATH=\(.mount_path)"')"

# Fetch the accessor using Vault's API, including namespace in the header if provided
ACCESSOR=$(curl -s \
  --header "X-Vault-Token: $VAULT_TOKEN" \
  --header "X-Vault-Namespace: $VAULT_NAMESPACE" \
  --request GET "$VAULT_ADDR/v1/sys/mounts" | jq -r '.data."'"$MOUNT_PATH"'/".accessor')

# Output the accessor in a JSON format so that Terraform can parse it
echo "{\"accessor\": \"$ACCESSOR\"}"
