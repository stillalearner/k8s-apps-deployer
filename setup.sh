#!/bin/bash

# K8s Apps Deployer - Quick Setup Script
# This script sets up the environment and optionally creates a kind cluster

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Functions
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is not installed"
        return 1
    fi
}

# Header
echo "=========================================="
echo "  K8s Apps Deployer - Setup Script"
echo "=========================================="
echo ""

# Check prerequisites
print_info "Checking prerequisites..."

MISSING_DEPS=0

if ! check_command python3; then
    MISSING_DEPS=1
fi

if ! check_command pip3; then
    MISSING_DEPS=1
fi

if ! check_command kubectl; then
    print_warning "kubectl is not installed (optional, but recommended)"
fi

if ! check_command kind; then
    print_warning "kind is not installed (optional, for local testing)"
fi

if [ $MISSING_DEPS -eq 1 ]; then
    print_error "Missing required dependencies. Please install them first."
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
REQUIRED_VERSION="3.8"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    print_error "Python 3.8+ required. Found: $PYTHON_VERSION"
    exit 1
fi

print_success "Python version: $PYTHON_VERSION"

# Setup virtual environment
echo ""
print_info "Setting up virtual environment..."

if [ -d "venv" ]; then
    print_warning "Virtual environment already exists. Skipping creation."
else
    python3 -m venv venv
    print_success "Virtual environment created"
fi

# Activate virtual environment
print_info "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
print_info "Upgrading pip..."
pip install --upgrade pip --quiet

# Install the package
echo ""
print_info "Installing k8s-apps-deployer..."
pip install -e . --quiet
print_success "Package installed successfully"

# Verify installation
echo ""
print_info "Verifying installation..."

if command -v k8sdeploy &> /dev/null || command -v k8s-deployer &> /dev/null; then
    print_success "CLI commands are available"
else
    print_warning "CLI commands not found in PATH (you can use: python -m k8sdeployer.cli)"
fi

# Test the installation
echo ""
print_info "Testing installation..."
python -m k8sdeployer.cli list > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_success "Installation verified"
    echo ""
    print_info "Available applications:"
    python -m k8sdeployer.cli list
else
    print_error "Installation verification failed"
    exit 1
fi

# Kind cluster setup (optional)
echo ""
read -p "Do you want to create a kind cluster for testing? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! command -v kind &> /dev/null; then
        print_error "kind is not installed. Please install it first:"
        echo "  brew install kind  # macOS"
        echo "  or visit: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    else
        CLUSTER_NAME="k8s-deployer-test"
        
        # Check if cluster already exists
        if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
            print_warning "Kind cluster '${CLUSTER_NAME}' already exists"
            read -p "Do you want to delete and recreate it? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_info "Deleting existing cluster..."
                kind delete cluster --name "$CLUSTER_NAME"
            else
                print_info "Using existing cluster"
            fi
        fi
        
        # Create cluster if it doesn't exist
        if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
            print_info "Creating kind cluster '${CLUSTER_NAME}'..."
            kind create cluster --name "$CLUSTER_NAME"
            print_success "Kind cluster created"
        fi
        
        # Set kubectl context
        print_info "Setting kubectl context..."
        kubectl config use-context "kind-${CLUSTER_NAME}"
        print_success "Kubectl context set to kind-${CLUSTER_NAME}"
        
        # Verify cluster
        print_info "Verifying cluster connection..."
        if kubectl cluster-info &> /dev/null; then
            print_success "Cluster is accessible"
            echo ""
            kubectl get nodes
        else
            print_error "Failed to connect to cluster"
        fi
    fi
fi

# Summary
echo ""
echo "=========================================="
print_success "Setup completed successfully!"
echo "=========================================="
echo ""
print_info "Next steps:"
echo ""
echo "1. Activate the virtual environment:"
echo "   ${GREEN}source venv/bin/activate${NC}"
echo ""
echo "2. List available applications:"
echo "   ${GREEN}k8sdeploy list${NC}"
echo "   ${GREEN}# or: python -m k8sdeployer.cli list${NC}"
echo ""
echo "3. Deploy an application (example):"
echo "   ${GREEN}k8sdeploy deploy basic-pod -n basic-pod -v${NC}"
echo "   ${GREEN}k8sdeploy deploy mysql -n database -v${NC}"
echo ""
echo "4. Validate deployment:"
echo "   ${GREEN}k8sdeploy validate basic-pod -n basic-pod${NC}"
echo ""
echo "5. Remove application:"
echo "   ${GREEN}k8sdeploy remove basic-pod -n basic-pod${NC}"
echo ""
print_info "For more details, see USAGE_KIND.md"
echo ""
