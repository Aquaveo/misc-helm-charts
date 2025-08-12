#!/bin/bash

# Helm chart validation script for geoserver-official
# This script validates the chart templates and checks for common issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    print_error "Helm is not installed. Please install Helm first."
    exit 1
fi

print_info "Starting GeoServer Helm chart validation..."

# Change to chart directory
CHART_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$CHART_DIR"

print_info "Validating chart structure..."

# Check required files
required_files=(
    "Chart.yaml"
    "values.yaml"
    "templates/deployment.yaml"
    "templates/service.yaml"
    "templates/_helpers.tpl"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        print_success "✓ $file exists"
    else
        print_error "✗ $file is missing"
        exit 1
    fi
done

# Lint the chart
print_info "Running helm lint..."
if helm lint .; then
    print_success "✓ Helm lint passed"
else
    print_error "✗ Helm lint failed"
    exit 1
fi

# Test template rendering with default values
print_info "Testing template rendering with default values..."
if helm template test-release . > /dev/null; then
    print_success "✓ Default template rendering passed"
else
    print_error "✗ Default template rendering failed"
    exit 1
fi

# Test template rendering with example configurations
print_info "Testing example configurations..."

example_files=(
    "examples/development.yaml"
    "examples/production.yaml"
    "examples/postgres-integration.yaml"
)

for example in "${example_files[@]}"; do
    if [[ -f "$example" ]]; then
        print_info "Testing $example..."
        if helm template test-release . -f "$example" > /dev/null; then
            print_success "✓ $example template rendering passed"
        else
            print_error "✗ $example template rendering failed"
            exit 1
        fi
    else
        print_warning "Example file $example not found"
    fi
done

# Check for common template issues
print_info "Checking for common template issues..."

# Check if all values are properly referenced
print_info "Checking value references..."
if grep -r "\.Values\.geoserver\." templates/ > /dev/null 2>&1; then
    print_error "Found old geoserver.* value references in templates"
    print_error "Please update templates to use flattened structure"
    grep -r "\.Values\.geoserver\." templates/ | head -5
    exit 1
else
    print_success "✓ No old geoserver.* value references found"
fi

# Generate templates with different configurations to check for errors
print_info "Testing specific configurations..."

# Test with extensions enabled
cat << EOF > /tmp/test-extensions.yaml
extensions:
  install: true
  stable:
    - "wps"
    - "css"
  community:
    - "ogcapi-features"
cors:
  enabled: true
postgres:
  jndi:
    enabled: true
    host: "postgres"
    database: "test"
    username: "user"
    password: "pass"
EOF

if helm template test-release . -f /tmp/test-extensions.yaml > /dev/null; then
    print_success "✓ Extensions configuration test passed"
else
    print_error "✗ Extensions configuration test failed"
    exit 1
fi

# Cleanup
rm -f /tmp/test-extensions.yaml

print_success "All validation tests passed!"
print_info "Chart is ready for use."

echo
print_info "Quick start commands:"
echo "  helm install my-geoserver ."
echo "  helm install my-geoserver . -f examples/development.yaml"
echo "  helm install my-geoserver . -f examples/production.yaml"
