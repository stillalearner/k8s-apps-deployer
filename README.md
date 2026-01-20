# K8s Apps Deployer

A simplified tool for deploying applications to Kubernetes and OpenShift clusters. This tool supports both Kubernetes and OpenShift clusters and can authenticate using either kubeconfig files or service account tokens.

## Features

- **Multi-cluster support**: Works with both Kubernetes and OpenShift
- **Flexible authentication**: Supports kubeconfig files or service account tokens
- **Ansible-based**: Uses Ansible playbooks for deployment, making it easy to extend
- **Simple CLI**: Easy-to-use command-line interface
- **Role-based**: Applications are defined as Ansible roles

## Quick Start

The easiest way to get started is using the setup script:

```bash
# Run the setup script (creates venv, installs dependencies, optionally sets up kind cluster)
./setup.sh
```

Or manually:

```bash
# 1. Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # On macOS/Linux

# 2. Install the package
pip install -e .
```

## Installation

### Automated Setup (Recommended)

Use the provided setup script for a complete setup:

```bash
./setup.sh
```

This script will:
- Check prerequisites (Python 3.8+, pip, kubectl, kind)
- Create a virtual environment
- Install all dependencies
- Optionally create a kind cluster for testing
- Verify the installation

### Manual Installation

```bash
# Clone the repository
git clone <repository-url>
cd k8s-apps-deployer

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On macOS/Linux

# Install the package
pip install -e .
```

The package will be installed in editable mode, so you can make changes to the source code without reinstalling.

## Usage

### Authentication

The tool supports two authentication methods:

1. **Kubeconfig** (default): Uses your default kubeconfig file (`~/.kube/config`)
   ```bash
   k8sdeploy deploy mysql -n mysql
   ```

2. **Service Account Token**: Use environment variables or CLI flags
   ```bash
   export K8S_TOKEN="your-token"
   export K8S_SERVER="https://api.example.com:6443"
   k8sdeploy deploy mysql -n mysql
   ```

   Or use CLI flags:
   ```bash
   k8sdeploy deploy mysql -n mysql --token "your-token" --server "https://api.example.com:6443"
   ```

### Commands

#### List available applications

```bash
k8sdeploy list
```

#### Deploy an application

```bash
k8sdeploy deploy <application> -n <namespace>
```

Options:
- `-n, --namespace`: Namespace to deploy to
- `-f, --force-cleanup`: Cleanup application before deploying
- `-e, --extra-vars`: Extra variables as JSON string
- `--kubeconfig`: Path to kubeconfig file
- `--token`: Service account token
- `--server`: API server URL (required with --token)
- `--insecure-skip-tls-verify`: Skip TLS certificate verification
- `-v, --verbose`: Enable verbose logging

Example:
```bash
k8sdeploy deploy mysql -n mysql
k8sdeploy deploy mysql -n mysql -e '{"storage_size": "5Gi"}'
```

#### Remove an application

```bash
k8sdeploy remove <application> -n <namespace>
```

#### Validate an application

```bash
k8sdeploy validate <application> -n <namespace>
```

## Available Applications

The following applications are available:

- **mysql**: MySQL database with persistent storage
- **mongodb**: MongoDB database with persistent storage
- **redis**: Redis cache with persistent storage
- **basic-pod**: Simple nginx pod
- **pvc**: Persistent volume claim

## Architecture

The project is structured as follows:

```
k8s-apps-deployer/
├── src/
│   └── k8sdeployer/
│       ├── __init__.py
│       ├── cli.py              # CLI interface
│       ├── cluster.py           # Cluster connection management
│       ├── application_factory.py  # Application factory
│       ├── apps/
│       │   ├── base.py          # Base application class
│       │   └── ansible_app.py   # Ansible-based application
│       └── ansible/
│           ├── deploy.yml       # Deploy playbook
│           ├── remove.yml       # Remove playbook
│           ├── validate.yml     # Validate playbook
│           └── roles/           # Application roles
│               ├── mysql/
│               ├── mongodb/
│               ├── redis/
│               ├── basic-pod/
│               └── pvc/
├── pyproject.toml
├── requirements.txt
└── README.md
```

## Adding New Applications

To add a new application, create a new Ansible role in `src/k8sdeployer/ansible/roles/`:

1. Create the role directory structure:
   ```
   roles/your-app/
   ├── defaults/
   │   └── main.yml
   ├── tasks/
   │   ├── main.yml
   │   ├── deploy.yml
   │   ├── cleanup.yml
   │   └── validate.yml
   └── templates/  # Optional
   ```

2. The role should handle three actions:
   - `deploy`: Deploy the application (when `with_deploy: true`)
   - `cleanup`: Remove the application (when `with_cleanup: true`)
   - `validate`: Validate the application (when `with_validate: true`)

3. Use the `k8s` Ansible module for all Kubernetes/OpenShift operations to ensure compatibility with both platforms.

## Differences from oadp-apps-deployer

This project is a simplified version with the following improvements:

1. **Simplified architecture**: Removed complex inheritance hierarchies
2. **K8s/OpenShift compatibility**: All roles use `k8s` Ansible module instead of `oc` commands
3. **Flexible authentication**: Supports both kubeconfig and service account tokens
4. **Cleaner CLI**: Simplified command structure
5. **Better error handling**: More informative error messages

## License

Apache-2.0
