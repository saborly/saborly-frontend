#!/bin/bash

# Saborly VPS Server Setup Script
# This script sets up the VPS server for deploying the Flutter web app

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="saborly.es"
EMAIL="admin@saborly.es"  # Change this to your email
PROJECT_DIR="/var/www/saborly"
FLUTTER_VERSION="3.25.1"

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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root"
    exit 1
fi

log_info "Starting Saborly VPS server setup..."
log_info "Domain: $DOMAIN"
log_info "Project directory: $PROJECT_DIR"

# Check for port conflicts
log_step "Checking port availability..."
if command -v netstat &> /dev/null || command -v ss &> /dev/null; then
    if command -v ss &> /dev/null; then
        PORT_80=$(ss -tuln | grep ':80 ' || true)
        PORT_443=$(ss -tuln | grep ':443 ' || true)
    else
        PORT_80=$(netstat -tuln | grep ':80 ' || true)
        PORT_443=$(netstat -tuln | grep ':443 ' || true)
    fi
    
    if [ -n "$PORT_80" ] && ! echo "$PORT_80" | grep -q nginx; then
        log_warn "Port 80 is already in use. Nginx will handle this."
    fi
    if [ -n "$PORT_443" ] && ! echo "$PORT_443" | grep -q nginx; then
        log_warn "Port 443 is already in use. Nginx will handle this."
    fi
    log_info "Ports 80 and 443 will be used by Nginx for saborly.es"
fi

# Update system
log_step "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install essential packages
log_step "Installing essential packages..."
apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    nginx \
    certbot \
    python3-certbot-nginx \
    ufw \
    fail2ban

# Install Flutter
log_step "Installing Flutter..."
if ! command -v flutter &> /dev/null; then
    if [ ! -d "/opt/flutter" ]; then
        log_info "Downloading Flutter ${FLUTTER_VERSION} (this may take a few minutes)..."
        cd /opt
        
        # Download Flutter with progress
        if ! wget --progress=bar:force "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -O flutter.tar.xz; then
            log_error "Failed to download Flutter. Trying alternative method..."
            # Try with curl as fallback
            if ! curl -L "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o flutter.tar.xz; then
                log_error "Failed to download Flutter with both wget and curl."
                log_error "Please check your internet connection and try again."
                exit 1
            fi
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
        
        # Add Flutter to PATH
        export PATH="$PATH:/opt/flutter/bin"
        echo 'export PATH="$PATH:/opt/flutter/bin"' >> /etc/profile
        echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
        
        # Verify Flutter works
        log_info "Configuring Flutter..."
        if ! /opt/flutter/bin/flutter config --enable-web; then
            log_error "Failed to configure Flutter"
            exit 1
        fi
        
        # Accept Flutter licenses (non-blocking)
        /opt/flutter/bin/flutter doctor --android-licenses || true
        
        log_info "Flutter installed successfully"
    else
        log_info "Flutter directory already exists in /opt/flutter"
        export PATH="$PATH:/opt/flutter/bin"
    fi
else
    log_info "Flutter is already installed"
fi

# Create project directories
log_step "Creating project directories..."
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/web"
mkdir -p "$PROJECT_DIR/backups"
mkdir -p "$PROJECT_DIR/logs"

# Setup Nginx
log_step "Setting up Nginx..."
if [ -f "./nginx/saborly.conf" ]; then
    cp "./nginx/saborly.conf" /etc/nginx/sites-available/saborly.conf
else
    log_warn "Nginx config file not found in current directory. Please copy it manually."
fi

# Enable site
if [ -f "/etc/nginx/sites-available/saborly.conf" ]; then
    ln -sf /etc/nginx/sites-available/saborly.conf /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    nginx -t
    systemctl restart nginx
    log_info "Nginx configured"
fi

# Setup firewall
log_step "Configuring firewall..."
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 'Nginx Full'
ufw allow 80/tcp
ufw allow 443/tcp
log_info "Firewall configured"

# Setup SSL certificate
log_step "Setting up SSL certificate with Let's Encrypt..."
log_info "Make sure your domain $DOMAIN points to this server's IP address"
read -p "Press Enter to continue with SSL setup, or Ctrl+C to cancel..."

certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" --non-interactive --agree-tos --email "$EMAIL" --redirect

# Setup auto-renewal for SSL
log_step "Setting up SSL auto-renewal..."
systemctl enable certbot.timer
systemctl start certbot.timer

# Setup Fail2Ban
log_step "Configuring Fail2Ban..."
systemctl enable fail2ban
systemctl start fail2ban

# Set permissions
log_step "Setting permissions..."
chown -R www-data:www-data "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR"

# Create deployment script symlink
log_step "Creating deployment script..."
if [ -f "./scripts/deploy.sh" ]; then
    chmod +x ./scripts/deploy.sh
    cp ./scripts/deploy.sh /usr/local/bin/saborly-deploy
    chmod +x /usr/local/bin/saborly-deploy
    log_info "Deployment script installed. Run 'saborly-deploy' to deploy."
fi

# Create a placeholder index.html if web directory is empty
if [ ! -f "$PROJECT_DIR/web/index.html" ]; then
    log_info "Creating placeholder index.html..."
    cat > "$PROJECT_DIR/web/index.html" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Saborly - Deployment in Progress</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
        }
        h1 { margin: 0 0 20px 0; }
        p { font-size: 18px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Saborly</h1>
        <p>Server is ready. Run the deployment script to deploy the app.</p>
    </div>
</body>
</html>
EOF
    chown www-data:www-data "$PROJECT_DIR/web/index.html"
fi

log_info "${GREEN}Server setup completed successfully!${NC}"
log_info ""
log_info "Next steps:"
log_info "1. Make sure your domain $DOMAIN DNS points to this server"
log_info "2. Run the deployment script: saborly-deploy"
log_info "3. Your app will be available at: https://$DOMAIN"
log_info ""
log_info "Useful commands:"
log_info "  - Deploy: saborly-deploy"
log_info "  - Check Nginx status: systemctl status nginx"
log_info "  - Check SSL certificate: certbot certificates"
log_info "  - View logs: tail -f /var/log/nginx/saborly-error.log"
