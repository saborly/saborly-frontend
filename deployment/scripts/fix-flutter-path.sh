#!/bin/bash

# Quick fix script to ensure Flutter is in PATH
# Run this if deploy.sh says Flutter is not found

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "Fixing Flutter PATH..."

# Check if Flutter exists in /opt/flutter
if [ -d "/opt/flutter/bin" ]; then
    log_info "Flutter found in /opt/flutter/bin"
    
    # Add to current session
    export PATH="$PATH:/opt/flutter/bin"
    
    # Verify it works
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version 2>&1 | head -n 1)
        log_info "✓ Flutter is now available: $FLUTTER_VERSION"
        log_info ""
        log_info "You can now run: sudo ./deploy.sh"
    else
        log_error "Flutter still not found after adding to PATH"
        exit 1
    fi
else
    log_error "Flutter not found in /opt/flutter"
    log_info "Please run setup-server.sh first to install Flutter"
    exit 1
fi
