#!/bin/bash

# Port Availability Check Script
# Checks if ports 80 and 443 are available for Nginx

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

log_info "Checking port availability for Saborly deployment..."
echo ""

# Check port 80
log_info "Checking port 80 (HTTP)..."
if command -v ss &> /dev/null; then
    PORT_80=$(ss -tuln | grep ':80 ' || true)
elif command -v netstat &> /dev/null; then
    PORT_80=$(netstat -tuln | grep ':80 ' || true)
else
    log_error "Neither 'ss' nor 'netstat' is available. Install net-tools: apt-get install net-tools"
    exit 1
fi

if [ -z "$PORT_80" ]; then
    log_info "✓ Port 80 is available"
else
    if echo "$PORT_80" | grep -q nginx; then
        log_info "✓ Port 80 is used by Nginx (expected)"
    else
        log_warn "⚠ Port 80 is in use by:"
        echo "$PORT_80"
        log_warn "Nginx will bind to port 80. Make sure this won't conflict."
    fi
fi

echo ""

# Check port 443
log_info "Checking port 443 (HTTPS)..."
if command -v ss &> /dev/null; then
    PORT_443=$(ss -tuln | grep ':443 ' || true)
elif command -v netstat &> /dev/null; then
    PORT_443=$(netstat -tuln | grep ':443 ' || true)
fi

if [ -z "$PORT_443" ]; then
    log_info "✓ Port 443 is available"
else
    if echo "$PORT_443" | grep -q nginx; then
        log_info "✓ Port 443 is used by Nginx (expected)"
    else
        log_warn "⚠ Port 443 is in use by:"
        echo "$PORT_443"
        log_warn "Nginx will bind to port 443. Make sure this won't conflict."
    fi
fi

echo ""

# Check other common ports
log_info "Checking other services on the server..."
echo ""

PORTS_TO_CHECK=(3000 3001 8080 8000)
for port in "${PORTS_TO_CHECK[@]}"; do
    if command -v ss &> /dev/null; then
        PORT_STATUS=$(ss -tuln | grep ":$port " || true)
    else
        PORT_STATUS=$(netstat -tuln | grep ":$port " || true)
    fi
    
    if [ -n "$PORT_STATUS" ]; then
        log_info "Port $port is in use (other services - OK)"
    fi
done

echo ""
log_info "Summary:"
log_info "- Saborly will use ports 80 and 443 via Nginx"
log_info "- Other ports (3000, 3001, etc.) are used by different services"
log_info "- Multiple domains can coexist on the same server using Nginx virtual hosts"
echo ""
