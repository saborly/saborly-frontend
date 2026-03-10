# Saborly Deployment Package

This directory contains all the necessary files and scripts to deploy the Saborly Flutter web application to a VPS server.

## Directory Structure

```
deployment/
├── nginx/
│   └── saborly.conf          # Nginx configuration file
├── scripts/
│   ├── setup-server.sh       # Initial server setup script
│   ├── setup-ssl.sh          # SSL certificate setup script
│   └── deploy.sh             # Application deployment script
└── DEPLOYMENT.md             # Detailed deployment guide
```

## Quick Start

1. **Upload files to server**:
   ```bash
   scp -r deployment/ root@161.97.151.182:/root/
   ```

2. **Run initial setup**:
   ```bash
   ssh root@161.97.151.182
   cd /root/deployment/scripts
   chmod +x setup-server.sh
   ./setup-server.sh
   ```

3. **Deploy application**:
   ```bash
   cd /root/deployment/scripts
   chmod +x deploy.sh
   sudo ./deploy.sh
   ```

## Files Description

### Nginx Configuration (`nginx/saborly.conf`)

- Configured for domain: saborly.es
- HTTPS with Let's Encrypt SSL
- Security headers
- Gzip compression
- Proper caching for Flutter web assets
- SPA routing support

### Setup Server Script (`scripts/setup-server.sh`)

Installs and configures:
- System packages
- Flutter SDK
- Nginx web server
- SSL certificates (Let's Encrypt)
- Firewall rules
- Fail2Ban
- Project directories

### Setup SSL Script (`scripts/setup-ssl.sh`)

Sets up SSL certificate using Let's Encrypt Certbot.

### Deploy Script (`scripts/deploy.sh`)

Deploys the Flutter web application:
- Creates backups
- Clones/updates repository
- Builds Flutter web app
- Deploys to production
- Reloads Nginx

## Requirements

- Ubuntu/Debian VPS server
- Root or sudo access
- Domain DNS configured to point to server IP
- SSH access to the server

## Port Information

- **Saborly uses**: Ports 80 (HTTP) and 443 (HTTPS) via Nginx
- **Other services**: Ports 3000, 3001, etc. are used by other applications (e.g., Meerabs)
- **No conflicts**: Multiple domains can coexist on the same server using Nginx virtual hosts

## Documentation

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed step-by-step instructions.

## Server Information

- **Domain**: saborly.es
- **IP**: 161.97.151.182
- **Repository**: https://github.com/saborly/saborly-frontend.git
