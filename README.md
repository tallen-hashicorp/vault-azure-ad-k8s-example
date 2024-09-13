Got it! I’ll keep all the steps intact while still improving the clarity and flow. Here’s the updated version with everything retained:

---

# Vault Azure AD Kubernetes Example

This repository demonstrates how to use HashiCorp Vault Enterprise to enable self-service provisioning of Azure Kubernetes (K8s) resources. We will walk through the setup of Vault, dynamic credential generation using Azure AD, and the use of Terraform modules to manage these configurations.

## Prerequisites

Before proceeding, ensure you have the following:

- [Vault CLI installed](https://developer.hashicorp.com/vault/docs/install)
- A local Kubernetes (K8s) cluster
- An Azure account with necessary permissions
- A Vault Enterprise license

## Starting Vault

We will use a local Kubernetes cluster with Vault Enterprise deployed via Helm.

### Step 1: Prepare the Vault License

Before deploying Vault, create a Kubernetes secret containing your Vault Enterprise license. Replace `vault.hclic` with the actual path to your license file.

Alternatively, you can copy the `vault.hclic` file into this directory (the `.gitignore` file already prevents this from being committed).

### Step 2: Deploy Vault

Run the `install-vault.sh` script to install and initialize Vault:

```bash
source install-vault.sh
```

This script will set up Vault and configure it for this example.

### Step 3: Accessing Vault

To access Vault locally, set up port forwarding in the background with the following command:

```bash
kubectl -n vault port-forward services/vault 8200:8200 2>&1 >/dev/null & PORT_FORWARD_PID=$!; echo $PORT_FORWARD_PID > pid
```

This forwards port `8200` from Vault to your local machine and stores the process ID in a file named `pid`. Alternatively, you can run:

```bash
kubectl -n vault port-forward services/vault 8200:8200
```

This will occupy your terminal until manually stopped.

### Stopping the Port Forwarding

If you used the background method, stop the process by running:

```bash
kill $(cat pid)
```

This frees up port `8200` on your local machine.

You can use Vault’s root token (output at the end of the setup script) to log in. Alternatively, check the `init.json` file for the root token.

## Cleanup Vault

To remove all Vault components and related Kubernetes resources, run:

```bash
kubectl delete ns vault
```

---

## 0. Basic Setup

The initial setup creates foundational components for the Vault platform team. Aside from the namespace creation, the rest of the setup is an example of how modules can be structured. We use Vault's root token for simplicity in this example.

### Components Created:
- **Vault Platform Team Namespace**: A dedicated namespace for the platform team.
- **Full Control Policy**: A policy granting full control over the platform team namespace.
- **Userpass Authentication**: A basic user-password authentication method.
- **JWT Authentication**: For external service integration.

### Prerequisites:

Make sure the Vault root token is set as the `TF_VAR_vault_token` environment variable. If you ran the previous Vault setup script with `source`, this variable should already be set. If not, run the following command with your root token:

```bash
export TF_VAR_vault_token="s.xxxxxxx"
```

### Steps to Build the Initial Vault Configuration:

1. Navigate to the setup directory:

```bash
cd 0-platform-team-initial-setup
terraform init
terraform apply
```

This creates the platform team namespace and additional components in Vault.

---

## 1. Dynamic Credentials

This section covers dynamic credential generation using the parent namespace Azure Secret Engine to configure the Tenant Azure Secret Engine.

### Pros
- Easy to set up using Terraform.

### Cons
- Terraform must be rerun every 30 days to refresh credentials.
- Long-lived credentials need rotation.
- Can't run this all at once. It can take up to an hour for the credentials to work when rotated!

### Notes
- If the platform team root is rotated, the tenant stops working. To fix this:
    1. Run `terraform apply` on `1-dynamic-credentials-tenant1`.
    2. Wait 1 minute to 3 hours for Azure to persist the new service principal (this delay is an Azure issue, not Vault).
    3. Possible errors include:
        - `Insufficient privileges to complete the operation.` (Seen when Azure hasn't yet persisted the App registrations.)
        - `The identity of the calling application could not be established.` (Seen when the App registration is deleted.)
        - `Application not found in the directory.` (Seen later after App registration is deleted.)
    4. Testing example:
        - 9:40 PM: Created client_id `cbc17df7-7c4f-47e9-abcc-5525f5252eab` manually.
        - 9:51 PM: Ran `terraform apply` on `1-dynamic-credentials-tenant1` to make tenant using that client_id.
        - 9:53 PM: Tested `vault read azure/creds/tenant1` and got `The identity of the calling application could not be established.`, will test tomorrow.
        - Still running into `was not found in the directory 'Default Directory'`. This may be a permission issue when trying to grant owner access.
        - Believed to be fixed now.

### To Deploy

Obtain your Azure Tenant ID, Client ID, Client Secret, and Subscription ID by following the steps in the [Azure Credentials Setup Guide](./azure-credentials-setup.md).

### Step 1: Deploy Azure Secret Engine for Platform Team

Set the environment variables:

```bash
export TF_VAR_tenant_id=""
export TF_VAR_client_id=""
export TF_VAR_client_secret=""
export TF_VAR_subscription_id=""
```

Then deploy using Terraform:

```bash
cd ..
cd 1-dynamic-credentials-platform-team
terraform init
terraform apply
```

To manually test:

```bash
export VAULT_NAMESPACE="platform-team"
vault list azure/roles
vault write -f azure/rotate-root 
vault read azure/creds/platform-team
unset VAULT_NAMESPACE
```

### Step 2: Provision Tenant

Next, provision a tenant. This only requires the `TF_VAR_subscription_id` and `TF_VAR_tenant_id`. The `client_id` and `client_secret` will be generated automatically using the platform team’s Azure Secret Engine.

```bash
cd ..
cd 1-dynamic-credentials-tenant1
terraform init
terraform apply
```

To manually test (wait 10-15 minutes before running this):

```bash
export VAULT_NAMESPACE="tenant1"
vault read azure/config
vault list azure/roles
vault write -f azure/rotate-root 
vault read azure/creds/tenant1
unset VAULT_NAMESPACE
```

---

## 2. Plugin Workload Identity Federation (WIF)

In this section, we will integrate Workload Identity Federation (WIF) to enable secure, token-based authentication between HashiCorp Vault and Azure AD. WIF allows workloads running in Kubernetes or other environments to authenticate with Azure AD without needing long-lived credentials. By using short-lived tokens, this approach enhances security and scalability when accessing Azure resources.

### Pros
- Short-lived credentials, enhancing security.

### Cons
- Requires Vault 1.17 or later.
- Added complexity:
    - `identity/oidc` needs to be configured and enabled.
    - Ensure that Vault's openid-configuration and public JWKS APIs are network-reachable by Azure.
    - Short-lived credentials are more secure but require more frequent rotations and integration complexity.
- Ensure `api_addr` is set to the external API URL.

### Notes
- HCP Vault is 1.15 🤦‍♂️

### To Deploy

For WIF, Vault must be deployed using HTTPS and be network-reachable by Azure. Here's how to set it up on EC2:

1. Use the [quick-ec2-tf](https://github.com/tallen-hashicorp/quick-ec2-tf) repository to provision an EC2 instance.
2. Set up an A record on Route 53, e.g., `vault.the-tech-tutorial.com`.
3. Install Nginx and Certbot for SSL:

```bash
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx unzip
```

4. Obtain a Let's Encrypt certificate:

```bash
sudo certbot --nginx -d vault.the-tech-tutorial.com
```

5. Install Vault:

```bash
wget https://releases.hashicorp.com/vault/1.17.5+ent/vault_1.17.5+ent_linux_amd64.zip
unzip vault_1.17.5+ent_linux_amd64.zip
sudo mv vault /usr/bin
```

6. Start Vault:

```bash
mkdir -p ./vault/data
sudo vault server -config=vault.hcl
```

7. Configure Vault:

```bash
export VAULT_ADDR="https://vault.the-tech-tutorial.com:8200/"
vault operator init
vault operator unseal
vault operator unseal
vault operator unseal
export VAULT_TOKEN=hvs.******
```

Set the necessary variables and deploy the WIF setup using Terraform:

```bash
export TF_VAR_vault_addr=$VAULT_ADDR
export TF_VAR_vault_token=$VAULT_TOKEN
export TF_VAR_subscription_id=""
export TF_VAR_tenant_id=""
export TF_VAR_client_id=""
```

Now, navigate to the directory and apply:

```bash
cd 2-wif-initial-setup
terraform init
terraform apply
```

Follow the Azure and Vault documentation for more details on setting up WIF.

---

## Choosing Between Dynamic or Existing Service Principals

Dynamic service principals are preferred if the desired Azure resources can be provided via the RBAC system. This approach is decoupled from other clients and offers the best audit granularity.

However, some Azure services cannot use the RBAC system. In these cases, an existing service principal may be needed, but be mindful of Azure’s limit on the number of passwords for a single Application.

---
