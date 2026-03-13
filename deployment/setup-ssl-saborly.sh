#!/bin/bash
# ============================================================
#  Setup SSL Certificate for saborly.es
#  Run on server: bash setup-ssl-saborly.sh
# ============================================================

echo "================================================================"
echo "  🔒  Setting up SSL certificate for saborly.es"
echo "================================================================"

# ── Step 1: Ensure Nginx config exists ────────────────────────
NGINX_CONF="/etc/nginx/sites-available/saborly"

if [ ! -f "$NGINX_CONF" ]; then
    echo ""
    echo "⚠️  Nginx config not found at $NGINX_CONF"
    echo "   Creating temporary HTTP-only config for certbot..."
    
    # Create temporary HTTP-only config for ACME challenge
    cat > "$NGINX_CONF" << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name saborly.es www.saborly.es;

    root /var/www/saborly;
    index index.html;

    # Allow Let's Encrypt ACME challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF
    
    # Enable site
    ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/saborly
    rm -f /etc/nginx/sites-enabled/default
    
    # Test and reload
    nginx -t && systemctl reload nginx
    echo "   ✅ Temporary HTTP config created and enabled."
fi

# ── Step 2: Ensure certbot directory exists ───────────────────
mkdir -p /var/www/certbot
chmod 755 /var/www/certbot

# ── Step 3: Run certbot ────────────────────────────────────────
echo ""
echo "▶ Obtaining SSL certificate via Let's Encrypt..."
echo "   Domain: saborly.es"
echo ""

certbot --nginx -d saborly.es -d www.saborly.es \
    --non-interactive \
    --agree-tos \
    --email admin@saborly.es \
    --redirect

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================================"
    echo "  ✅  SSL certificate installed successfully!"
    echo "  🌍  https://saborly.es"
    echo "================================================================"
    
    # Test nginx config
    echo ""
    echo "▶ Testing Nginx configuration..."
    nginx -t && systemctl reload nginx
    echo "   ✅ Nginx reloaded with SSL configuration."
else
    echo ""
    echo "================================================================"
    echo "  ❌  Certificate installation failed!"
    echo "  Check the error messages above."
    echo "================================================================"
    exit 1
fi
