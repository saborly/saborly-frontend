#!/bin/bash

# SSL Certificate Setup Script for Saborly
# This script sets up SSL certificate using Let's Encrypt

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
DOMAIN="saborly.es"
EMAIL="admin@saborly.es"  # Change this to your email

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root"
    exit 1
fi

log_info "Setting up SSL certificate for $DOMAIN"

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    log_error "Certbot is not installed. Installing..."
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
fi

# Check if domain points to this server
log_info "Verifying domain DNS configuration..."
SERVER_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip)
log_info "Server IP: $SERVER_IP"
log_info "Please verify that $DOMAIN and www.$DOMAIN point to $SERVER_IP"
read -p "Press Enter to continue, or Ctrl+C to cancel..."

# Obtain SSL certificate
log_info "Obtaining SSL certificate from Let's Encrypt..."
certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    --redirect

# Test auto-renewal
log_info "Testing certificate auto-renewal..."
certbot renew --dry-run

log_info "${GREEN}SSL certificate setup completed!${NC}"
log_info "Certificate will auto-renew. Check status with: certbot certificates"
