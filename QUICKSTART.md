# Quick Start Guide

Get up and running with k8s-apps-deployer in minutes!

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- kubectl (optional, for cluster interaction)
- kind (optional, for local Kubernetes cluster)

## Option 1: Automated Setup (Recommended)

Run the setup script:

```bash
./setup.sh
```

The script will:
- ✅ Check all prerequisites
- ✅ Create a virtual environment
- ✅ Install all dependencies
- ✅ Optionally create a kind cluster
- ✅ Verify the installation

## Option 2: Manual Setup

### Step 1: Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate  # On macOS/Linux
# On Windows: venv\Scripts\activate
```

### Step 2: Install Package

```bash
pip install --upgrade pip
pip install -e .
```

### Step 3: Verify Installation

```bash
# List available applications
k8sdeploy list
# or
python -m k8sdeployer.cli list
```

## Using with Kind Cluster

### Create a Kind Cluster (if not already done)

```bash
# Create a new kind cluster
kind create cluster --name k8s-deployer-test

# Verify it's running
kubectl cluster-info --context kind-k8s-deployer-test
```

### Deploy Your First Application

```bash
# Make sure venv is activated
source venv/bin/activate

# List available apps
k8sdeploy list

# Deploy a basic pod
k8sdeploy deploy basic-pod -n basic-pod -v

# Check the deployment
kubectl get pods -n basic-pod

# Validate the deployment
k8sdeploy validate basic-pod -n basic-pod

# Remove when done
k8sdeploy remove basic-pod -n basic-pod
```

## Common Examples

### Deploy MySQL

```bash
k8sdeploy deploy mysql -n database -v
k8sdeploy validate mysql -n database
kubectl get all -n database
```

### Deploy MongoDB

```bash
k8sdeploy deploy mongodb -n database -v
k8sdeploy validate mongodb -n database
```

### Deploy with Custom Variables

```bash
# Deploy MySQL with custom storage size
k8sdeploy deploy mysql -n database \
  -e '{"storage_size": "5Gi", "mysql_version": "8.0"}' \
  -v
```

## Troubleshooting

### ModuleNotFoundError

If you see `ModuleNotFoundError: No module named 'k8sdeployer'`:

```bash
# Make sure venv is activated
source venv/bin/activate

# Reinstall the package
pip install -e .
```

### Cannot Connect to Cluster

```bash
# Check kubectl connection
kubectl cluster-info
kubectl get nodes

# For kind clusters, verify context
kubectl config get-contexts
kubectl config use-context kind-<cluster-name>
```

### Command Not Found

If `k8sdeploy` command is not found:

```bash
# Use the Python module instead
python -m k8sdeployer.cli list
python -m k8sdeployer.cli deploy basic-pod -n basic-pod
```

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [USAGE_KIND.md](USAGE_KIND.md) for kind-specific usage
- Explore available applications: `k8sdeploy list`
- Check Ansible roles in `src/k8sdeployer/ansible/roles/` to understand deployments

## Available Applications

- **basic-pod**: Simple nginx pod
- **mysql**: MySQL database with persistent storage
- **mongodb**: MongoDB database with persistent storage
- **redis**: Redis cache with persistent storage
- **pvc**: Persistent volume claim

## Getting Help

- Check the logs with `-v` flag for verbose output
- Review Ansible playbooks in `src/k8sdeployer/ansible/`
- Check application defaults in `src/k8sdeployer/ansible/roles/<app>/defaults/main.yml`
