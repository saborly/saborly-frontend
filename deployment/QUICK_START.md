# Quick Start Guide - Saborly Deployment

## 🚀 Fast Deployment (5 Minutes)

### Step 1: Connect to Server
```bash
ssh root@161.97.151.182
```

### Step 2: Clone Repository
```bash
cd /root
git clone https://github.com/saborly/saborly-frontend.git
cd saborly-frontend/deployment/scripts
```

### Step 3: Run Setup
```bash
chmod +x setup-server.sh
./setup-server.sh
```
**Note**: Make sure DNS for saborly.es points to 161.97.151.182 before SSL setup.

### Step 4: Deploy
```bash
chmod +x deploy.sh
sudo ./deploy.sh
```

### Step 5: Verify
Visit: **https://saborly.es**

---

## 📋 Pre-Deployment Checklist

- [ ] Domain DNS configured (saborly.es → 161.97.151.182)
- [ ] SSH access to server working
- [ ] Root/sudo access available
- [ ] Email address for SSL certificate notifications

---

## 🔄 Update Application

```bash
sudo saborly-deploy
```

---

## 🛠️ Common Commands

```bash
# Check Nginx
systemctl status nginx

# View logs
tail -f /var/log/nginx/saborly-error.log

# Check SSL
certbot certificates

# Reload Nginx
systemctl reload nginx
```

---

## 📞 Need Help?

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed instructions.
