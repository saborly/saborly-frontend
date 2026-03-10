#!/bin/bash
# ============================================================
#  Saborly VPS — One-Time Server Bootstrap Script
#  Run as root on: 161.97.151.182
#  Usage: bash setup-vps.sh
# ============================================================
set -euo pipefail

DOMAIN="saborly.es"
WEB_ROOT="/var/www/saborly"
NGINX_CONF="/etc/nginx/sites-available/saborly"
DEPLOY_USER="deploy"        # non-root user for SSH deployments

echo "================================================================"
echo "  🚀  Saborly VPS Setup — $DOMAIN"
echo "================================================================"

# ── 1. System Update ─────────────────────────────────────────
echo ""
echo "▶ [1/9] Updating system packages..."
apt-get update -y && apt-get upgrade -y
apt-get install -y \
    curl wget git unzip \
    nginx \
    certbot python3-certbot-nginx \
    ufw \
    htop \
    fail2ban

# ── 2. Create Deploy User ─────────────────────────────────────
echo ""
echo "▶ [2/9] Creating deploy user '$DEPLOY_USER'..."
if id "$DEPLOY_USER" &>/dev/null; then
    echo "   User '$DEPLOY_USER' already exists — skipping."
else
    adduser --disabled-password --gecos "" "$DEPLOY_USER"
    # Allow deploy user to reload nginx without password
    echo "$DEPLOY_USER ALL=(ALL) NOPASSWD: /bin/systemctl reload nginx" \
        >> /etc/sudoers.d/deploy-nginx
    chmod 440 /etc/sudoers.d/deploy-nginx
    echo "   User '$DEPLOY_USER' created."
fi

# ── 3. Configure Web Root ─────────────────────────────────────
echo ""
echo "▶ [3/9] Setting up web root at $WEB_ROOT..."
mkdir -p "$WEB_ROOT"
chown -R "$DEPLOY_USER":www-data "$WEB_ROOT"
chmod -R 755 "$WEB_ROOT"
mkdir -p /var/www/certbot   # used by ACME challenge during cert issuance

# ── 4. Configure Firewall (UFW) ───────────────────────────────
echo ""
echo "▶ [4/9] Configuring firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh          # port 22
ufw allow 80/tcp       # HTTP
ufw allow 443/tcp      # HTTPS
ufw --force enable
ufw status verbose

# ── 5. Install Nginx Config ───────────────────────────────────
echo ""
echo "▶ [5/9] Installing Nginx site configuration..."

# Temporarily serve HTTP only for Let's Encrypt (before SSL cert)
cat > "$NGINX_CONF" << 'NGINX_HTTP_ONLY'
server {
    listen 80;
    listen [::]:80;
    server_name saborly.es www.saborly.es;

    root /var/www/saborly;
    index index.html;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINX_HTTP_ONLY

# Enable site
ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/saborly
# Disable default site
rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
nginx -t
systemctl enable nginx
systemctl reload nginx
echo "   Nginx configured and running (HTTP only for now)."

# ── 6. Obtain SSL Certificate ─────────────────────────────────
echo ""
echo "▶ [6/9] Obtaining SSL certificate via Let's Encrypt..."
echo "   ⚠  Ensure DNS A record for saborly.es → 161.97.151.182 is live before this step!"
echo ""
read -p "   DNS is pointed correctly? (y/N): " dns_ready
if [[ "$dns_ready" =~ ^[Yy]$ ]]; then
    certbot --nginx \
        -d "$DOMAIN" \
        -d "www.$DOMAIN" \
        --non-interactive \
        --agree-tos \
        --email admin@saborly.es \
        --redirect
    echo "   ✅ SSL certificate obtained!"
else
    echo "   ⏭  Skipping SSL — run 'certbot --nginx -d saborly.es -d www.saborly.es' manually once DNS is ready."
fi

# ── 7. Install Full Nginx Config (with HTTPS) ────────────────
echo ""
echo "▶ [7/9] Installing full Nginx config (HTTP→HTTPS)..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/nginx/saborly.conf" ]; then
    cp "$SCRIPT_DIR/nginx/saborly.conf" "$NGINX_CONF"
    nginx -t && systemctl reload nginx
    echo "   Full config applied."
else
    echo "   ⚠  nginx/saborly.conf not found at $SCRIPT_DIR — copy it manually."
fi

# ── 8. Configure Fail2Ban ─────────────────────────────────────
echo ""
echo "▶ [8/9] Hardening with Fail2Ban..."
cat > /etc/fail2ban/jail.local << 'FAIL2BAN'
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true

[nginx-http-auth]
enabled = true

[nginx-botsearch]
enabled = true
FAIL2BAN
systemctl enable fail2ban
systemctl restart fail2ban
echo "   Fail2Ban active."

# ── 9. Auto-Renew SSL (Cron) ─────────────────────────────────
echo ""
echo "▶ [9/9] Setting up SSL auto-renewal cron..."
(crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet --nginx && systemctl reload nginx") | crontab -
echo "   Cron job added (runs daily at 03:00)."

# ── Done ─────────────────────────────────────────────────────
echo ""
echo "================================================================"
echo "  ✅  VPS Setup Complete!"
echo ""
echo "  Next steps:"
echo "  1. Point DNS A record → 161.97.151.182  (if not done)"
echo "  2. Add deploy user's SSH public key:"
echo "     mkdir -p /home/$DEPLOY_USER/.ssh"
echo "     echo 'YOUR_PUBLIC_KEY' >> /home/$DEPLOY_USER/.ssh/authorized_keys"
echo "     chown -R $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh"
echo "     chmod 700 /home/$DEPLOY_USER/.ssh"
echo "     chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys"
echo "  3. Run the deploy script: bash deployment/deploy.sh"
echo "  4. Visit https://saborly.es"
echo "================================================================"
