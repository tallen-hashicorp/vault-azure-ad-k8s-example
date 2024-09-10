# Vault Azure AD K8s Example

This repository demonstrates how to use HashiCorp Vault Enterprise to enable self-service provisioning of Azure Kubernetes (K8s) resources.

## Prerequisites
* [Vault CLI installed](https://developer.hashicorp.com/vault/docs/install)
* A local Kubernetes (K8s) cluster
* An Azure account
* A Vault Enterprise license

## Starting Vault

For this example, we are using a local Kubernetes cluster with Vault Enterprise deployed via Helm.

### Step 1: Prepare the Vault License

Before deploying Vault, you need to create a Kubernetes secret containing your Vault Enterprise license. Replace `vault.hclic` with the actual path to your license file.

If you prefer, you can copy the `vault.hclic` file into this directory (the `.gitignore` file already includes this to prevent it from being committed).

### Step 2: Deploy Vault

Run the `install-vault.sh` script to set up Vault quickly:

```bash
./install-vault.sh
```

This will install, start, and initialize Vault.

### Step 3: Accessing Vault

To access Vault locally, run the following command to set up port forwarding:

```bash
kubectl -n vault port-forward services/vault 8200:8200 2>&1 >/dev/null & PORT_FORWARD_PID=$!; echo $PORT_FORWARD_PID > pid
```

This will forward port `8200` to your local machine.

To stop the port forwarding, simply run:

```bash
kill $PORT_FORWARD_PID
```

## Cleanup Vault

To remove all Vault components and related Kubernetes resources, run:

```bash
kubectl delete ns vault
```

---

## Configure Vault 

