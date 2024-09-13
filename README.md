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

Before deploying Vault, you need to create a Kubernetes secret containing your Vault Enterprise license. Replace `vault.hclic` with the actual path to your license file.

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

# 0. Basic Setup

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

# 1. Dynamic Credentials
This section covers dynamic credential generation using the parent namespace Azure Secret Engine to configure the Tenant Azure Secret Engine.

![diagram](./docs/1-dynamic-creds2.png)

### Pros
- Easy to set up using Terraform.

### Cons
- Terraform must be rerun every 30 days to refresh credentials.
- Long-lived credentials need rotation.
- Can't run this all at once. The problem I found is that it takes up to an hour for the credentials to work when rotated!

### Notes
- If the platform team root is rotated, the tenant stops working. To fix this:
    1. Run `terraform apply` on `1-dynamic-credentials-tenant1`.
    2. Wait 1 minute to 3 hours for Azure to persist the new service principal (this delay is an Azure issue, not Vault).
    3. Possible errors include:
        - `Insufficient privileges to complete the operation.` Seen this when Azure has not yet persisted the App registrations.
        - `The identity of the calling application could not be established.` Seen when the App registration is deleted.
        - `Application not found in the directory.` Seen this later after App registration is deleted.

## To Deploy

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

![diagram](./docs/1-dynamic-creds1.png)

---

# 2. Plugin Workload Identity Federation (WIF)

In this section, we will integrate Workload Identity Federation (WIF) to enable secure, token-based authentication between HashiCorp Vault and Azure AD. WIF allows workloads running in Kubernetes or other environments to authenticate with Azure AD without needing long-lived credentials. By using short-lived tokens, this approach enhances security and scalability when accessing Azure resources. We will configure the necessary Vault plugins and demonstrate how Terraform can manage WIF setup, ensuring that your platform and tenant teams can securely access Azure resources without manual credential handling.

![wip](./docs/2-wip-creds1.png)

### Pros
- Short-lived credentials, enhancing security.

### Cons
- Requires Vault 1.17 or later.
- Added complexity:
    - `identity/oidc` needs to be configured and enabled.
    - Ensure that Vault's openid-configuration and public JWKS APIs are network-reachable by Azure.
    - Short-lived credentials enhance security but are more complex to integrate and manage frequent credential rotations effectively.
- Ensure `api_addr` is set to external API URL.
- Would not be able to have an azure mount in the tenats that use the `client_id` & `client_secret` generated from the `platform-team` mount as they are so short lived. You can however setup azure mounts in each tenant with the same config as platform-team
    - An altaneraitce would be to take advantage of `group_policy_application_mode` : [Secrets management across namespaces without hierarchical relationship](https://developer.hashicorp.com/vault/tutorials/enterprise/namespaces-secrets-sharing)

### Notes
- HCP Vault is 1.15 🤦‍♂️
- `vault_identity_oidc` gets created every time!
- No matching federated identity record found for presented assertion audience 'https://vault.the-tech-tutorial.com:8200/v1/platform-team/identity/oidc/plugins'
    - This looks correct however I feel this is a MSFS cache issue, wait to 12:00 to test again
- If get `No matching federated identity record found for presented assertion issuer` then the `vault_identity_oidc` in `modules/2-vault-azure-secrets-engine/main.tf` us incorrect


## To Deploy
For this, we need Vault deployed using HTTPS, and it must be network-reachable by Azure.

One approach for this was to use a proxy; this did not work in my testing, and I've switched to deploying Vault on an EC2 node as described before. However, my previous proxy notes can be found [here](./vault-proxy-notes.md).

In order to have a Vault node that is available to HTTPS, and it must be network-reachable by Azure, I am using a different Vault install on EC2.

* Use the [quick-ec2-tf](https://github.com/tallen-hashicorp

/quick-ec2-tf) repository to provision an EC2 instance.

* Set up an A record on your personal Route 53 domain pointing to the EC2 instance, e.g., `vault.the-tech-tutorial.com`.

* Update the system and install Nginx and Certbot for SSL management:

```bash
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx unzip
```

* Use Certbot to obtain a Let’s Encrypt SSL certificate for your domain. **Replace domain with yours**:

```bash
sudo certbot --nginx -d vault.the-tech-tutorial.com
```

* Install Vault:

```bash
wget https://releases.hashicorp.com/vault/1.17.5+ent/vault_1.17.5+ent_linux_amd64.zip
unzip vault_1.17.5+ent_linux_amd64.zip
sudo mv vault /usr/bin
```

* Copy the license file over to `/tmp/vault.hclic`.

* Copy the [vault.hclic](./jumpbox/vault.hcl) to the EC2 instance. **Ensure you update the cert file locations to match yours**.

* Start Vault:

```bash
mkdir -p ./vault/data
sudo vault server -config=vault.hcl
```

* Configure Vault **from your Laptop**. **Amend to match your URL**:

```bash
unset VAULT_TOKEN
export VAULT_ADDR="https://vault.the-tech-tutorial.com:8200"
vault operator init

vault operator unseal
vault operator unseal
vault operator unseal

export VAULT_TOKEN=hvs.******
```

Next, let's configure Vault:

```bash
export TF_VAR_vault_addr=$VAULT_ADDR
export TF_VAR_vault_token=$VAULT_TOKEN
export TF_VAR_subscription_id=""
export TF_VAR_tenant_id=""
export TF_VAR_client_id=""
```

1. Now we can set up Vault. Run the following to set up the initial namespace, etc., in Vault:

```bash
cd 2-wif-initial-setup
terraform init
terraform apply
```

Now we need to configure Azure. A more detailed guide can be found for Vault [here](https://developer.hashicorp.com/vault/docs/secrets/azure#plugin-workload-identity-federation-wif) and Azure [here](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust?pivots=identity-wif-apps-methods-azp#other-identity-providers).

2. Find your app registration created earlier, probably called `Vault Platform Team` in the app registrations section of the Microsoft Entra admin center. Select **Certificates & Secrets** in the left nav pane, select the **Federated Credentials** tab, and select **Add Credential**.

3. Set the following values, replacing the URL with your Vault URL. Change the Subject Identifier to match something similar to this `plugin-identity:0AUpw:secret:azure_38b36e27` `plugin-identity:<NAMESPACE>:secret:<AZURE_MOUNT_ACCESSOR>`. The Audience must be the same as step 4 below

| Field              | Value                                               |
|--------------------|-----------------------------------------------------|
| Issuer             | `https://{VAULT_URL}:8200/v1/platform-team/identity/oidc/plugins` |
| Subject identifier | `plugin-identity:0AUpw:secret:azure_38b36e27`         |
| Name               | `Vault`                                             |
| Audience           |  `vault.the-tech-tutorial.com:8200/v1/platform-team/identity/oidc/plugins` |


![azure](./docs/azure-screenshot1.png)

4. Next, configure the `identity_token_audience` variable we will use in the next step. Replace `{VAULT_HOST}` in the following command (this does not need `http://`, so it will be something like `vault.example/v1/identity/oidcs/plugins`):

```bash
export TF_VAR_identity_token_audience="vault.the-tech-tutorial.com:8200/v1/platform-team/identity/oidc/plugins"
```

5. Now we will set up the Azure Secrets Engine in the platform team account. You probably have `TF_VAR_client_id`, `TF_VAR_tenant_id`, and `TF_VAR_subscription_id` already set, but if not, go back to [Step 1: Deploy Azure Secret Engine for Platform Team](#step-1-deploy-azure-secret-engine-for-platform-team). 

```bash
cd ..
cd 2-wif-credentials-platform-team
terraform init
terraform apply
```

6. You can test this with
```bash
export VAULT_NAMESPACE="platform-team"
vault read azure/config
vault list azure/roles
vault read azure/creds/platform-team
unset VAULT_NAMESPACE
```

**NOTE:** You can test that the keys are correct by hitting this [URL](https://vault.the-tech-tutorial.com:8200/v1/platform-team/identity/oidc/plugins/.well-known/openid-configuration).

## Choosing between dynamic or existing service principals
Dynamic service principals are preferred if the desired Azure resources can be provided via the RBAC system and Azure roles defined in the Vault role. This form of credential is completely decoupled from any other clients, is not subject to permission changes after issuance, and offers the best audit granularity.

Access to some Azure services cannot be provided with the RBAC system, however. In these cases, an existing service principal can be set up with the necessary access, and Vault can create new passwords for this service principal. Any changes to the service principal permissions affect all clients. Furthermore, Azure does not provide any logging with regard to which credential was used for an operation.

An important limitation when using an existing service principal is that Azure limits the number of passwords for a single application. This limit is based on application object size and isn't firmly specified, but in practice, hundreds of passwords can be issued per application. An error will be returned if the object size is reached. This limit can be managed by reducing the role TTL or by creating another Vault role against a different Azure service principal configured with the same permissions.