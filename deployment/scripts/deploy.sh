#!/bin/bash

# Saborly Flutter Web Deployment Script
# This script builds and deploys the Flutter web app to the VPS server

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/var/www/saborly"
WEB_DIR="$PROJECT_DIR/web"
BACKUP_DIR="$PROJECT_DIR/backups"
REPO_URL="https://github.com/saborly/saborly-frontend.git"
BRANCH="main"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root or with sudo"
    exit 1
fi

log_info "Starting Saborly deployment..."

# Create directories if they don't exist
log_info "Creating directories..."
mkdir -p "$PROJECT_DIR"
mkdir -p "$BACKUP_DIR"
mkdir -p "$WEB_DIR"

# Backup existing deployment
if [ -d "$WEB_DIR" ] && [ "$(ls -A $WEB_DIR)" ]; then
    log_info "Creating backup of existing deployment..."
    BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"
    tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" -C "$PROJECT_DIR" web
    log_info "Backup created: $BACKUP_NAME.tar.gz"
fi

# Clone or update repository
if [ -d "$PROJECT_DIR/repo" ]; then
    log_info "Updating repository..."
    cd "$PROJECT_DIR/repo"
    git fetch origin
    git reset --hard origin/$BRANCH
    git clean -fd
else
    log_info "Cloning repository..."
    cd "$PROJECT_DIR"
    git clone "$REPO_URL" repo
    cd repo
    git checkout $BRANCH
fi

# Check Flutter installation and add to PATH if needed
log_info "Checking Flutter installation..."

# Add Flutter to PATH if it exists in /opt/flutter
if [ -d "/opt/flutter/bin" ]; then
    export PATH="$PATH:/opt/flutter/bin"
    log_info "Added /opt/flutter/bin to PATH"
fi

# Check if Flutter is now available
if ! command -v flutter &> /dev/null; then
    # Try to find Flutter in common locations
    if [ -f "/opt/flutter/bin/flutter" ]; then
        export PATH="$PATH:/opt/flutter/bin"
        log_info "Using Flutter from /opt/flutter/bin"
    elif [ -f "$HOME/flutter/bin/flutter" ]; then
        export PATH="$PATH:$HOME/flutter/bin"
        log_info "Using Flutter from $HOME/flutter/bin"
    else
        log_error "Flutter is not installed or not in PATH."
        log_info "Attempting to install Flutter..."
        
        # Try to install Flutter
        if [ ! -d "/opt/flutter" ]; then
            log_info "Flutter not found. Please run install-flutter.sh first."
            log_info "Or run: cd /root/saborly-frontend/deployment/scripts && sudo ./install-flutter.sh"
            exit 1
        fi
            
            # Verify download
            if [ ! -f "flutter.tar.xz" ] || [ ! -s "flutter.tar.xz" ]; then
                log_error "Downloaded file is missing or empty"
                exit 1
            fi
            
            log_info "Extracting Flutter..."
            if ! tar xf flutter.tar.xz; then
                log_error "Failed to extract Flutter archive"
                exit 1
            fi
            
            # Verify extraction
            if [ ! -d "flutter/bin" ] || [ ! -f "flutter/bin/flutter" ]; then
                log_error "Flutter extraction failed or incomplete"
                exit 1
            fi
            
            rm -f flutter.tar.xz
            export PATH="$PATH:/opt/flutter/bin"
            echo 'export PATH="$PATH:/opt/flutter/bin"' >> /etc/profile
            
            # Verify Flutter works
            log_info "Configuring Flutter..."
            if ! /opt/flutter/bin/flutter config --enable-web; then
                log_error "Failed to configure Flutter"
                exit 1
            fi
            
            log_info "Flutter installed successfully"
        else
            export PATH="$PATH:/opt/flutter/bin"
            log_info "Flutter directory exists, adding to PATH"
        fi
    fi
fi

# Verify Flutter is working
if ! command -v flutter &> /dev/null; then
    log_error "Flutter is still not available. Please run setup-server.sh first."
    exit 1
fi

# Show Flutter version
FLUTTER_VERSION_OUTPUT=$(flutter --version 2>&1 | head -n 1 || echo "Unknown")
log_info "Flutter found: $FLUTTER_VERSION_OUTPUT"

# Get Flutter dependencies
log_info "Getting Flutter dependencies..."
cd "$PROJECT_DIR/repo"
flutter pub get

# Build Flutter web app
log_info "Building Flutter web app (this may take a few minutes)..."
flutter build web --release --web-renderer canvaskit

# Check if build was successful
if [ ! -d "$PROJECT_DIR/repo/build/web" ]; then
    log_error "Build failed! build/web directory not found."
    exit 1
fi

# Deploy to web directory
log_info "Deploying to web directory..."
rm -rf "$WEB_DIR"/*
cp -r "$PROJECT_DIR/repo/build/web"/* "$WEB_DIR"/

# Set proper permissions
log_info "Setting permissions..."
chown -R www-data:www-data "$WEB_DIR"
chmod -R 755 "$WEB_DIR"

# Test Nginx configuration
log_info "Testing Nginx configuration..."
if nginx -t; then
    log_info "Nginx configuration is valid"
    log_info "Reloading Nginx..."
    systemctl reload nginx
else
    log_error "Nginx configuration test failed!"
    exit 1
fi

log_info "${GREEN}Deployment completed successfully!${NC}"
log_info "Your app should now be available at: https://saborly.es"

# Cleanup old backups (keep last 5)
log_info "Cleaning up old backups..."
cd "$BACKUP_DIR"
ls -t | tail -n +6 | xargs -r rm -f

log_info "${GREEN}All done!${NC}"
