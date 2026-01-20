# Using k8s-apps-deployer with Kind Cluster

This guide explains how to use the k8s-apps-deployer project with a local Kind (Kubernetes in Docker) cluster.

## Quick Start

```bash
# 1. Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # On macOS/Linux

# 2. Install the package in editable mode (this installs dependencies too)
pip install --upgrade pip
pip install -e .

# 3. Verify kind cluster
kind get clusters
kubectl cluster-info

# 4. Use the tool
python -m k8sdeployer.cli list
python -m k8sdeployer.cli deploy basic-pod -v
# Or use the console script:
k8s-deployer list
k8s-deployer deploy basic-pod -v
```

## Prerequisites

1. **Kind cluster** - Make sure you have a Kind cluster running
2. **Python 3.7+** - Required for running the deployer
3. **kubectl** - Should be configured to connect to your Kind cluster
4. **Python dependencies**:
   - `kubernetes` - Kubernetes Python client
   - `openshift` - OpenShift Python client (for dynamic client)
   - `ansible-runner` - For executing Ansible playbooks
   - `ansible` - Ansible core

## Installation

### 1. Create and Activate Virtual Environment

It's recommended to use a Python virtual environment to isolate dependencies:

```bash
# Navigate to project root
cd /path/to/k8s-apps-deployer

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate

# On Windows:
# venv\Scripts\activate
```

You should see `(venv)` in your terminal prompt when activated.

**Note**: Always activate the virtual environment before running commands. To deactivate later, simply run `deactivate`.

### 2. Install the Package

With the virtual environment activated, install the package in editable mode. This will install all dependencies and make the package importable:

```bash
pip install --upgrade pip
pip install -e .
```

This installs the package in "editable" mode, meaning changes to the source code are immediately available without reinstalling. It also installs all dependencies from `setup.py`.

**Alternative**: If you prefer to install dependencies separately:
```bash
pip install -r requirements.txt
# Then set PYTHONPATH to include src directory
export PYTHONPATH="${PYTHONPATH}:$(pwd)/src"
```

### 3. Verify Kind Cluster is Running

```bash
# Check if kind cluster exists
kind get clusters

# If no cluster exists, create one
kind create cluster --name my-cluster

# Verify kubectl can connect
kubectl cluster-info --context kind-my-cluster
```

### 4. Verify Kubeconfig

The tool will automatically use your default kubeconfig (`~/.kube/config`). If your Kind cluster context is not the default, you can:

- Set the context: `kubectl config use-context kind-my-cluster`
- Or use the `--kubeconfig` flag when running commands

## Usage

### Basic Commands

**Important**: Make sure your virtual environment is activated and the package is installed (`pip install -e .`) before running commands.

The tool can be run in two ways:

**Option 1: Using Python module (recommended after `pip install -e .`):**
```bash
# Make sure venv is activated (you should see (venv) in prompt)
python -m k8sdeployer.cli [command] [options]
```

**Option 2: Using console script:**
```bash
# After installing with pip install -e .
k8s-deployer [command] [options]
```

**Option 3: Direct module execution (if PYTHONPATH is set):**
```bash
# If you didn't install with pip install -e ., set PYTHONPATH first:
export PYTHONPATH="${PYTHONPATH}:$(pwd)/src"
python -m src.k8sdeployer.cli [command] [options]
```

### 1. List Available Applications

```bash
python -m k8sdeployer.cli list
# Or: k8s-deployer list
```

This will show all available applications (roles) such as:
- `basic-pod`
- `mysql`
- `mongodb`
- `pvc`
- `redis`

### 2. Deploy an Application

#### Basic Deployment

```bash
# Deploy a basic pod to default namespace (uses role name as namespace)
python -m k8sdeployer.cli deploy basic-pod
# Or: k8s-deployer deploy basic-pod

# Deploy to a specific namespace
python -m k8sdeployer.cli deploy basic-pod -n my-namespace

# Deploy with verbose logging
python -m k8sdeployer.cli deploy basic-pod -v
```

#### Deploy MySQL

```bash
# Deploy MySQL (will create namespace 'mysql' if it doesn't exist)
python -m k8sdeployer.cli deploy mysql

# Deploy MySQL to a custom namespace
python -m k8sdeployer.cli deploy mysql -n database
```

#### Deploy with Custom Variables

```bash
# Deploy with extra variables (JSON format)
python -m k8sdeployer.cli deploy basic-pod \
  -e '{"app_name": "my-app", "image": "nginx:1.21", "port": 8080}'
```

#### Force Cleanup Before Deploy

```bash
# Remove existing deployment before deploying
python -m k8sdeployer.cli deploy basic-pod -f
```

### 3. Validate an Application

```bash
# Validate that the application is running correctly
python -m k8sdeployer.cli validate basic-pod

# Validate in specific namespace
python -m k8sdeployer.cli validate mysql -n database
```

### 4. Remove an Application

```bash
# Remove the application
python -m k8sdeployer.cli remove basic-pod

# Remove from specific namespace
python -m k8sdeployer.cli remove mysql -n database
```

## Examples

### Example 1: Deploy and Validate a Basic Pod

```bash
# Make sure venv is activated
source venv/bin/activate  # On macOS/Linux

# 1. List available apps
python -m k8sdeployer.cli list

# 2. Deploy basic-pod
python -m k8sdeployer.cli deploy basic-pod -v

# 3. Validate deployment
python -m k8sdeployer.cli validate basic-pod

# 4. Check with kubectl
kubectl get pods -n basic-pod

# 5. Clean up
python -m k8sdeployer.cli remove basic-pod
```

### Example 2: Deploy MySQL with Custom Namespace

```bash
# Make sure venv is activated
source venv/bin/activate  # On macOS/Linux

# Deploy MySQL to 'database' namespace
python -m k8sdeployer.cli deploy mysql -n database -v

# Validate
python -m k8sdeployer.cli validate mysql -n database

# Check resources
kubectl get all -n database

# Remove
python -m k8sdeployer.cli remove mysql -n database
```

### Example 3: Using Custom Kubeconfig

If you have multiple Kind clusters or a custom kubeconfig location:

```bash
# Specify kubeconfig path
python -m k8sdeployer.cli deploy basic-pod \
  --kubeconfig ~/.kube/config-kind-cluster

# Or use environment variable
export KUBECONFIG=~/.kube/config-kind-cluster
python -m k8sdeployer.cli deploy basic-pod
```

## Command-Line Options

### Global Options

- `-v, --verbose` - Enable verbose logging
- `--kubeconfig PATH` - Path to kubeconfig file (defaults to `~/.kube/config`)
- `--token TOKEN` - Service account token for authentication
- `--server URL` - API server URL (required with `--token`)
- `--insecure-skip-tls-verify` - Skip TLS certificate verification

### Deploy Command Options

- `application` - Application name to deploy (required)
- `-n, --namespace` - Namespace to deploy to
- `-f, --force-cleanup` - Cleanup application before deploying
- `-e, --extra-vars` - Extra variables as JSON string

### Remove Command Options

- `application` - Application name to remove (required)
- `-n, --namespace` - Namespace to remove from

### Validate Command Options

- `application` - Application name to validate (required)
- `-n, --namespace` - Namespace to validate in

## Troubleshooting

### Issue: ModuleNotFoundError: No module named 'k8sdeployer'

**Solution**: Install the package in editable mode:
```bash
# Make sure venv is activated
source venv/bin/activate  # On macOS/Linux

# Install in editable mode
pip install -e .
```

This makes the `k8sdeployer` module importable. After installation, use:
```bash
python -m k8sdeployer.cli [command]
```

### Issue: Cannot connect to cluster

**Solution**: Verify your kubeconfig is set correctly:
```bash
kubectl cluster-info
kubectl get nodes
```

### Issue: Permission denied

**Solution**: Make sure your kubeconfig has the right permissions:
```bash
chmod 600 ~/.kube/config
```

### Issue: Ansible errors

**Solution**: Make sure your virtual environment is activated and Ansible is installed:
```bash
# Activate venv first
source venv/bin/activate  # On macOS/Linux

# Then install/verify
pip install ansible ansible-runner
ansible --version
```

### Issue: Namespace doesn't exist

**Solution**: The tool should create namespaces automatically, but you can create manually:
```bash
kubectl create namespace my-namespace
```

## Advanced Usage

### Using Environment Variables

You can set connection details via environment variables:

```bash
# Activate venv first
source venv/bin/activate  # On macOS/Linux

# Set environment variables
export KUBECONFIG=~/.kube/config-kind-cluster
export K8S_TOKEN=your-token
export K8S_SERVER=https://your-server:6443

python -m k8sdeployer.cli deploy basic-pod
```

### Multiple Kind Clusters

If you have multiple Kind clusters:

```bash
# Activate venv
source venv/bin/activate  # On macOS/Linux

# Create multiple clusters
kind create cluster --name cluster1
kind create cluster --name cluster2

# Switch between them
kubectl config use-context kind-cluster1
python -m k8sdeployer.cli deploy basic-pod

kubectl config use-context kind-cluster2
python -m k8sdeployer.cli deploy basic-pod
```

## Next Steps

- Explore the available applications: `python -m k8sdeployer.cli list`
- Check the Ansible roles in `src/k8sdeployer/ansible/roles/` to understand what each application does
- Customize deployments by modifying role defaults or using `--extra-vars`
