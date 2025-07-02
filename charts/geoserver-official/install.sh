#!/bin/bash

# GeoServer Official Helm Chart Installation Script
# This script helps install GeoServer with common configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
RELEASE_NAME=""
NAMESPACE="default"
CONFIG_TYPE=""
CUSTOM_VALUES=""
DRY_RUN=false

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
usage() {
    cat << EOF
GeoServer Official Helm Chart Installation Script

Usage: $0 [OPTIONS]

Options:
    -n, --name RELEASE_NAME       Name for the Helm release (required)
    -s, --namespace NAMESPACE     Kubernetes namespace (default: default)
    -c, --config CONFIG_TYPE      Configuration type: dev, prod, postgres
    -f, --values VALUES_FILE      Custom values file path
    -d, --dry-run                 Perform a dry run without installing
    -h, --help                    Show this help message

Configuration Types:
    dev         Development configuration with demo data
    prod        Production configuration with security hardening
    postgres    PostgreSQL integration configuration

Examples:
    $0 --name my-geoserver --config dev
    $0 --name geoserver-prod --namespace geoserver --config prod
    $0 --name geoserver --config postgres --namespace default
    $0 --name custom-geoserver --values my-values.yaml
    $0 --name test-geoserver --config dev --dry-run

EOF
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check if connected to Kubernetes cluster
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to validate namespace
validate_namespace() {
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_warning "Namespace '$NAMESPACE' does not exist. Creating it..."
        kubectl create namespace "$NAMESPACE"
        print_success "Namespace '$NAMESPACE' created"
    fi
}

# Function to get values file based on config type
get_values_file() {
    case $CONFIG_TYPE in
        "dev")
            echo "examples/development.yaml"
            ;;
        "prod")
            echo "examples/production.yaml"
            ;;
        "postgres")
            echo "examples/postgres-integration.yaml"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to install GeoServer
install_geoserver() {
    local helm_args=()
    
    # Add release name and namespace
    helm_args+=(install "$RELEASE_NAME" .)
    helm_args+=(--namespace "$NAMESPACE")
    
    # Add values file if specified
    if [[ -n "$CONFIG_TYPE" ]]; then
        local values_file=$(get_values_file)
        if [[ -n "$values_file" ]]; then
            helm_args+=(--values "$values_file")
            print_info "Using configuration: $CONFIG_TYPE ($values_file)"
        fi
    fi
    
    # Add custom values file if specified
    if [[ -n "$CUSTOM_VALUES" ]]; then
        helm_args+=(--values "$CUSTOM_VALUES")
        print_info "Using custom values file: $CUSTOM_VALUES"
    fi
    
    # Add dry-run if specified
    if [[ "$DRY_RUN" == true ]]; then
        helm_args+=(--dry-run)
        print_info "Performing dry run..."
    fi
    
    # Add wait and timeout
    helm_args+=(--wait --timeout 10m)
    
    print_info "Installing GeoServer with Helm..."
    print_info "Command: helm ${helm_args[*]}"
    
    # Execute helm install
    if helm "${helm_args[@]}"; then
        if [[ "$DRY_RUN" != true ]]; then
            print_success "GeoServer installed successfully!"
            show_access_info
        else
            print_success "Dry run completed successfully!"
        fi
    else
        print_error "Failed to install GeoServer"
        exit 1
    fi
}

# Function to show access information
show_access_info() {
    print_info "Getting access information..."
    
    # Wait a moment for services to be ready
    sleep 5
    
    echo
    print_success "=== GeoServer Installation Complete ==="
    echo
    print_info "Release Name: $RELEASE_NAME"
    print_info "Namespace: $NAMESPACE"
    echo
    print_info "To access GeoServer:"
    
    # Check service type and provide appropriate access instructions
    local service_type=$(kubectl get service "$RELEASE_NAME-geoserver-official" -n "$NAMESPACE" -o jsonpath='{.spec.type}' 2>/dev/null || echo "Unknown")
    
    case $service_type in
        "NodePort")
            local node_port=$(kubectl get service "$RELEASE_NAME-geoserver-official" -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')
            print_info "Service Type: NodePort"
            print_info "Access URL: http://NODE_IP:$node_port/geoserver"
            echo "  Get NODE_IP with: kubectl get nodes -o wide"
            ;;
        "LoadBalancer")
            print_info "Service Type: LoadBalancer"
            print_info "Getting external IP (this may take a few minutes)..."
            local external_ip=$(kubectl get service "$RELEASE_NAME-geoserver-official" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "Pending")
            if [[ "$external_ip" != "Pending" && -n "$external_ip" ]]; then
                print_info "Access URL: http://$external_ip:8080/geoserver"
            else
                print_info "External IP is still pending. Check with:"
                echo "  kubectl get service $RELEASE_NAME-geoserver-official -n $NAMESPACE"
            fi
            ;;
        "ClusterIP"|*)
            print_info "Service Type: ClusterIP"
            print_info "Use port forwarding to access:"
            echo "  kubectl port-forward service/$RELEASE_NAME-geoserver-official 8080:8080 -n $NAMESPACE"
            print_info "Then access: http://localhost:8080/geoserver"
            ;;
    esac
    
    echo
    print_warning "Default Credentials:"
    print_warning "  Username: admin"
    print_warning "  Password: geoserver (or as configured)"
    print_warning "  IMPORTANT: Change the default password immediately!"
    
    echo
    print_info "Useful Commands:"
    echo "  Check pods: kubectl get pods -n $NAMESPACE"
    echo "  View logs: kubectl logs -f deployment/$RELEASE_NAME-geoserver-official -n $NAMESPACE"
    echo "  Run tests: helm test $RELEASE_NAME -n $NAMESPACE"
    echo "  Uninstall: helm uninstall $RELEASE_NAME -n $NAMESPACE"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -s|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_TYPE="$2"
            shift 2
            ;;
        -f|--values)
            CUSTOM_VALUES="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$RELEASE_NAME" ]]; then
    print_error "Release name is required. Use --name option."
    usage
    exit 1
fi

# Validate config type if provided
if [[ -n "$CONFIG_TYPE" && ! "$CONFIG_TYPE" =~ ^(dev|prod|postgres)$ ]]; then
    print_error "Invalid config type: $CONFIG_TYPE. Valid options: dev, prod, postgres"
    exit 1
fi

# Validate custom values file if provided
if [[ -n "$CUSTOM_VALUES" && ! -f "$CUSTOM_VALUES" ]]; then
    print_error "Custom values file not found: $CUSTOM_VALUES"
    exit 1
fi

# Main execution
print_info "Starting GeoServer installation..."
print_info "Release name: $RELEASE_NAME"
print_info "Namespace: $NAMESPACE"

check_prerequisites
validate_namespace
install_geoserver

print_success "Installation script completed!"
