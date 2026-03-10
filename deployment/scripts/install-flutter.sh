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

FLUTTER_DIR="/opt/flutter"

log_step "Detecting latest Flutter stable version..."

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
apt-get install -y curl wget tar xz-utils jq

# Create directory
mkdir -p /opt
cd /opt

# Remove old installation if exists
if [ -d "$FLUTTER_DIR" ]; then
    log_warn "Removing old Flutter installation..."
    rm -rf "$FLUTTER_DIR"
fi

# Get latest stable Flutter version
log_step "Fetching latest stable Flutter version..."
RELEASES_JSON=$(curl -s "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json")

if [ -z "$RELEASES_JSON" ]; then
    log_error "Failed to fetch Flutter releases information"
    exit 1
fi

# Extract latest stable version URL
FLUTTER_URL=$(echo "$RELEASES_JSON" | grep -o '"archive_url":"[^"]*stable[^"]*\.tar\.xz"' | head -n 1 | sed 's/"archive_url":"//;s/"//')

if [ -z "$FLUTTER_URL" ]; then
    # Fallback: try to parse JSON properly if jq is available
    if command -v jq &> /dev/null; then
        FLUTTER_URL=$(echo "$RELEASES_JSON" | jq -r '.releases[] | select(.channel=="stable") | .archive_url' | head -n 1)
    fi
fi

if [ -z "$FLUTTER_URL" ]; then
    log_error "Could not determine Flutter download URL"
    log_info "Trying alternative method..."
    # Alternative: use git to clone Flutter (slower but more reliable)
    log_info "Cloning Flutter from GitHub (this will take longer)..."
    cd /opt
    git clone https://github.com/flutter/flutter.git -b stable
    if [ -d "flutter/bin" ] && [ -f "flutter/bin/flutter" ]; then
        export PATH="$PATH:/opt/flutter/bin"
        echo 'export PATH="$PATH:/opt/flutter/bin"' >> /etc/profile
        /opt/flutter/bin/flutter config --enable-web
        log_info "Flutter installed successfully via Git"
        exit 0
    else
        log_error "Git clone also failed"
        exit 1
    fi
fi

# Download Flutter
log_step "Downloading Flutter from: $FLUTTER_URL"
log_info "This may take several minutes (file is ~1GB)..."

if wget --progress=bar:force "$FLUTTER_URL" -O flutter.tar.xz 2>&1 | tee /tmp/flutter_download.log | grep -q "saved\|100%"; then
    log_info "Download completed (wget)"
elif curl -L "$FLUTTER_URL" -o flutter.tar.xz --progress-bar; then
    log_info "Download completed (curl)"
else
    log_error "Failed to download Flutter"
    log_info "Trying Git clone as fallback..."
    cd /opt
    rm -f flutter.tar.xz
    git clone https://github.com/flutter/flutter.git -b stable
    if [ -d "flutter/bin" ] && [ -f "flutter/bin/flutter" ]; then
        export PATH="$PATH:/opt/flutter/bin"
        echo 'export PATH="$PATH:/opt/flutter/bin"' >> /etc/profile
        /opt/flutter/bin/flutter config --enable-web
        log_info "Flutter installed successfully via Git"
        exit 0
    else
        log_error "All download methods failed"
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
