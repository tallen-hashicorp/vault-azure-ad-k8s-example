#!/bin/bash

# Step 1: Create the namespace and Vault license secret, add the Helm repo, and install Vault
kubectl create namespace vault
kubectl -n vault create secret generic vault-licence --from-file=vault.hclic

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update hashicorp

helm install vault hashicorp/vault \
    --namespace vault \
    -f ./vault-deployment/override-values.yml

# Wait for Vault to be ready
echo "Waiting for Vault to be ready..."
kubectl wait --namespace vault --for=jsonpath='{.status.phase}'=Running pod/vault-0

# Step 2: Port-forward Vault to 8200 in the background
kubectl -n vault port-forward services/vault 8200:8200 &
PORT_FORWARD_PID=$!  # Save the process ID so we can close it later

# Wait for a few seconds to allow port-forwarding to establish
sleep 2 

# Step 3: Export VAULT_ADDR and initialize Vault
echo "Vault started, initing vault..."
export VAULT_ADDR='http://127.0.0.1:8200'
vault operator init -format=json > init.json

# Step 4: Extract the first 3 unseal keys from init.json and unseal Vault
for i in {0..2}; do
  UNSEAL_KEY=$(jq -r ".unseal_keys_b64[$i]" init.json)
  echo $UNSEAL_KEY
  vault operator unseal "$UNSEAL_KEY"
done

# Step 5: Extract the root token from init.json and output it
unset VAULT_TOKEN
VAULT_TOKEN=$(jq -r ".root_token" init.json)
printf "\033[1;32mRoot Token: %s\033[0m\n" "$VAULT_TOKEN"



# Step 6: Enable vault audit log
vault audit enable file file_path=/tmp/vault-audit-log.txt

# Export the root token to use in subsequent TF steps
unset TF_VAR_vault_token
export TF_VAR_vault_token=$(jq -r ".root_token" init.json)

# Step 7: Close the port-forwarding process
kill $PORT_FORWARD_PID
