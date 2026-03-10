# Saborly Web Deployment Guide

This guide will help you deploy the Saborly Flutter web application to your VPS server.

## Server Information

- **Domain**: saborly.es
- **Server IP**: 161.97.151.182
- **Server Type**: Cloud VPS 10 NVMe (Hub Europe)
- **Username**: root
- **GitHub Repository**: https://github.com/saborly/saborly-frontend.git

## Prerequisites

1. SSH access to the VPS server
2. Domain DNS configured to point to the server IP (161.97.151.182)
3. Root or sudo access on the server

## Important Notes

⚠️ **Port Information**: 
- Ports 3000 and 3001 are already in use by other services (Meerabs applications)
- Saborly deployment uses **ports 80 (HTTP) and 443 (HTTPS)** via Nginx
- No port conflicts will occur as Nginx handles standard web ports
- Multiple domains can be served on the same server using Nginx virtual hosts

## Step 1: Initial Server Setup

### 1.1 Connect to Your Server

```bash
ssh root@161.97.151.182
```

### 1.2 Check Port Availability (Optional)

Before setup, you can check port availability:

```bash
cd /root/saborly-frontend/deployment/scripts
chmod +x check-ports.sh
./check-ports.sh
```

**Note**: Ports 3000 and 3001 are already in use by other services (Meerabs). This is fine - Saborly uses ports 80/443 via Nginx, which won't conflict.

### 1.2 Upload Deployment Files

Upload the entire `deployment` folder to your server. You can use SCP:

```bash
# From your local machine
scp -r deployment/ root@161.97.151.182:/root/
```

Or clone the repository directly on the server:

```bash
# On the server
cd /root
git clone https://github.com/saborly/saborly-frontend.git
cd saborly-frontend
```

### 1.3 Run Initial Setup Script

```bash
cd /root/saborly-frontend/deployment/scripts
chmod +x setup-server.sh
./setup-server.sh
```

This script will:
- Update system packages
- Install Nginx, Certbot, and other dependencies
- Install Flutter
- Configure Nginx
- Set up firewall rules
- Create necessary directories

**Important**: Make sure your domain DNS (saborly.es) points to 161.97.151.182 before running the SSL setup.

## Step 2: Configure Domain DNS

Before setting up SSL, ensure your domain DNS records are configured:

- **A Record**: `saborly.es` → `161.97.151.182`
- **A Record**: `www.saborly.es` → `161.97.151.182`

You can verify DNS propagation with:

```bash
dig saborly.es +short
nslookup saborly.es
```

## Step 3: Setup SSL Certificate

### Option A: Automatic (Recommended)

The `setup-server.sh` script will automatically set up SSL if DNS is configured.

### Option B: Manual Setup

If you need to set up SSL manually:

```bash
cd /root/saborly-frontend/deployment/scripts
chmod +x setup-ssl.sh
# Edit setup-ssl.sh and update the EMAIL variable
./setup-ssl.sh
```

Or use Certbot directly:

```bash
certbot --nginx -d saborly.es -d www.saborly.es --non-interactive --agree-tos --email your-email@example.com --redirect
```

## Step 4: Deploy the Application

### 4.1 Manual Deployment

Run the deployment script:

```bash
cd /root/saborly-frontend/deployment/scripts
chmod +x deploy.sh
sudo ./deploy.sh
```

**If you encounter "Flutter is not installed" error:**

The deploy script will now automatically detect and use Flutter from `/opt/flutter/bin`. However, if you still get this error:

**Option 1: Install Flutter standalone (Recommended if setup failed)**
```bash
chmod +x install-flutter.sh
sudo ./install-flutter.sh
source /etc/profile
sudo ./deploy.sh
```

**Option 2: Reload PATH**
```bash
source /etc/profile
sudo ./deploy.sh
```

**Option 3: Use fix script**
```bash
chmod +x fix-flutter-path.sh
./fix-flutter-path.sh
sudo ./deploy.sh
```

**Option 4: Manual verification**
```bash
# Check if Flutter exists
ls -la /opt/flutter/bin/flutter

# If it exists, add to PATH manually
export PATH="$PATH:/opt/flutter/bin"
flutter --version
```

Or if you installed it system-wide:

```bash
sudo saborly-deploy
```

The deployment script will:
1. Backup existing deployment
2. Clone/update the repository
3. Install Flutter dependencies
4. Build the Flutter web app
5. Deploy to `/var/www/saborly/web`
6. Reload Nginx

### 4.2 Verify Deployment

After deployment, verify the site is working:

```bash
# Check Nginx status
systemctl status nginx

# Check if files are deployed
ls -la /var/www/saborly/web/

# Test the site
curl -I https://saborly.es
```

Visit https://saborly.es in your browser to verify.

## Step 5: Configure Nginx (If Needed)

The Nginx configuration is located at:

```
/etc/nginx/sites-available/saborly.conf
```

After making changes:

```bash
# Test configuration
nginx -t

# Reload Nginx
systemctl reload nginx
```

## Maintenance

### Updating the Application

To update the application with the latest code:

```bash
sudo saborly-deploy
```

This will automatically:
- Pull latest code from GitHub
- Build the app
- Deploy to production
- Reload Nginx

### Viewing Logs

```bash
# Nginx access logs
tail -f /var/log/nginx/saborly-access.log

# Nginx error logs
tail -f /var/log/nginx/saborly-error.log

# System logs
journalctl -u nginx -f
```

### SSL Certificate Renewal

SSL certificates auto-renew via Certbot. Check status:

```bash
# List certificates
certbot certificates

# Test renewal
certbot renew --dry-run

# Manual renewal
certbot renew
```

### Backup Management

Backups are stored in `/var/www/saborly/backups/`. The deployment script automatically keeps the last 5 backups.

To restore from backup:

```bash
cd /var/www/saborly/backups
tar -xzf backup-YYYYMMDD-HHMMSS.tar.gz -C /var/www/saborly/
chown -R www-data:www-data /var/www/saborly/web
systemctl reload nginx
```

## Troubleshooting

### Issue: Site not loading

1. Check Nginx status:
   ```bash
   systemctl status nginx
   ```

2. Check Nginx configuration:
   ```bash
   nginx -t
   ```

3. Check if files exist:
   ```bash
   ls -la /var/www/saborly/web/
   ```

4. Check firewall:
   ```bash
   ufw status
   ```

### Issue: SSL certificate errors

1. Verify DNS is pointing to the server:
   ```bash
   dig saborly.es +short
   ```

2. Check certificate status:
   ```bash
   certbot certificates
   ```

3. Renew certificate manually:
   ```bash
   certbot renew
   ```

### Issue: Build failures

1. Check Flutter installation:
   ```bash
   flutter doctor
   ```

2. Check Flutter version:
   ```bash
   flutter --version
   ```

3. Clear Flutter cache:
   ```bash
   flutter clean
   flutter pub get
   ```

### Issue: Permission errors

```bash
# Fix permissions
chown -R www-data:www-data /var/www/saborly
chmod -R 755 /var/www/saborly
```

## Security Best Practices

1. **Keep system updated**:
   ```bash
   apt-get update && apt-get upgrade -y
   ```

2. **Configure firewall** (already done by setup script):
   ```bash
   ufw status
   ```

3. **Fail2Ban** (already configured):
   ```bash
   systemctl status fail2ban
   ```

4. **Regular backups**: The deployment script creates automatic backups.

5. **Monitor logs**: Regularly check Nginx and system logs for suspicious activity.

## File Structure

```
/var/www/saborly/
├── web/              # Production web files (served by Nginx)
├── backups/          # Automatic backups
├── logs/             # Application logs
└── repo/             # Git repository clone
```

## Useful Commands

```bash
# Deploy application
saborly-deploy

# Check Nginx status
systemctl status nginx

# Reload Nginx
systemctl reload nginx

# Check SSL certificate
certbot certificates

# View Nginx logs
tail -f /var/log/nginx/saborly-error.log

# Check disk space
df -h

# Check memory usage
free -h
```

## Support

For issues or questions:
1. Check the logs first
2. Verify DNS configuration
3. Ensure all services are running
4. Check firewall rules

## Notes

- The deployment script requires root/sudo access
- Make sure Flutter is installed and in PATH
- Ensure domain DNS is properly configured before SSL setup
- Backups are automatically created before each deployment
- SSL certificates auto-renew via Certbot
