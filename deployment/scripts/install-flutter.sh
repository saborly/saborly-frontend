#!/bin/bash

# Standalone Flutter Installation Script
# Use this if Flutter installation fails in other scripts

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root"
    exit 1
fi

FLUTTER_VERSION="3.25.1"
FLUTTER_DIR="/opt/flutter"

log_step "Installing Flutter ${FLUTTER_VERSION}..."

# Check if already installed
if [ -d "$FLUTTER_DIR/bin" ] && [ -f "$FLUTTER_DIR/bin/flutter" ]; then
    log_info "Flutter already exists in $FLUTTER_DIR"
    export PATH="$PATH:$FLUTTER_DIR/bin"
    if command -v flutter &> /dev/null; then
        FLUTTER_VER=$(flutter --version 2>&1 | head -n 1)
        log_info "Flutter is working: $FLUTTER_VER"
        exit 0
    fi
fi

# Install required packages
log_step "Installing required packages..."
apt-get update
apt-get install -y curl wget tar xz-utils

# Create directory
mkdir -p /opt
cd /opt

# Remove old installation if exists
if [ -d "$FLUTTER_DIR" ]; then
    log_warn "Removing old Flutter installation..."
    rm -rf "$FLUTTER_DIR"
fi

# Download Flutter
log_step "Downloading Flutter (this may take several minutes)..."
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if wget --progress=bar:force "$FLUTTER_URL" -O flutter.tar.xz 2>&1 | grep -q "saved"; then
    log_info "Download completed"
elif curl -L "$FLUTTER_URL" -o flutter.tar.xz --progress-bar; then
    log_info "Download completed (using curl)"
else
    log_error "Failed to download Flutter"
    log_info "Trying to get latest stable version..."
    # Try to get latest version
    LATEST_URL=$(curl -s https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json | grep -o '"archive_url":"[^"]*stable[^"]*"' | head -n 1 | cut -d'"' -f4)
    if [ -n "$LATEST_URL" ]; then
        log_info "Downloading latest stable version..."
        wget --progress=bar:force "$LATEST_URL" -O flutter.tar.xz || curl -L "$LATEST_URL" -o flutter.tar.xz --progress-bar
    else
        log_error "Could not determine Flutter download URL"
        exit 1
    fi
fi

# Verify download
if [ ! -f "flutter.tar.xz" ] || [ ! -s "flutter.tar.xz" ]; then
    log_error "Downloaded file is missing or empty"
    exit 1
fi

FILE_SIZE=$(du -h flutter.tar.xz | cut -f1)
log_info "Downloaded file size: $FILE_SIZE"

# Extract Flutter
log_step "Extracting Flutter..."
if ! tar xf flutter.tar.xz; then
    log_error "Failed to extract Flutter archive"
    exit 1
fi

# Verify extraction
if [ ! -d "flutter/bin" ] || [ ! -f "flutter/bin/flutter" ]; then
    log_error "Flutter extraction failed or incomplete"
    exit 1
fi

# Cleanup
rm -f flutter.tar.xz

# Add to PATH
log_step "Configuring PATH..."
export PATH="$PATH:$FLUTTER_DIR/bin"
echo 'export PATH="$PATH:/opt/flutter/bin"' >> /etc/profile
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc

# Configure Flutter
log_step "Configuring Flutter..."
if ! $FLUTTER_DIR/bin/flutter config --enable-web; then
    log_error "Failed to configure Flutter"
    exit 1
fi

# Verify installation
log_step "Verifying installation..."
if command -v flutter &> /dev/null; then
    FLUTTER_VER=$(flutter --version 2>&1 | head -n 1)
    log_info "${GREEN}Flutter installed successfully!${NC}"
    log_info "Version: $FLUTTER_VER"
    
    # Run flutter doctor
    log_info "Running flutter doctor..."
    flutter doctor || true
    
    log_info ""
    log_info "Flutter is ready to use!"
    log_info "You may need to run: source /etc/profile"
else
    log_error "Flutter installation verification failed"
    log_info "Try running: source /etc/profile"
    exit 1
fi
