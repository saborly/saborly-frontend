#!/bin/bash
# ============================================================
#  Saborly — Flutter Web Build + Deploy Script
#  Usage: bash deployment/deploy.sh [--skip-build]
#
#  Requirements (local machine):
#    - Flutter SDK installed & in PATH
#    - SSH access to VPS (key-based auth recommended)
#    - rsync installed
# ============================================================
set -euo pipefail

# ── Config ───────────────────────────────────────────────────
VPS_IP="161.97.151.182"
VPS_USER="deploy"           # non-root deploy user (set up via setup-vps.sh)
                             # Use "root" if not yet configured
REMOTE_WEB_ROOT="/var/www/saborly"
BUILD_DIR="build/web"
SKIP_BUILD=false

# ── Parse arguments ──────────────────────────────────────────
for arg in "$@"; do
    case $arg in
        --skip-build) SKIP_BUILD=true ;;
    esac
done

echo "================================================================"
echo "  🚀  Saborly Deploy → $VPS_USER@$VPS_IP:$REMOTE_WEB_ROOT"
echo "================================================================"

# ── Step 1: Build Flutter Web ─────────────────────────────────
if [ "$SKIP_BUILD" = false ]; then
    echo ""
    echo "▶ [1/3] Building Flutter web (release)..."
    flutter clean
    flutter pub get
    flutter build web --release \
        --no-web-resources-cdn
    echo "   ✅ Build complete → $BUILD_DIR/"
else
    echo ""
    echo "▶ [1/3] Skipping build (--skip-build flag set)."
    if [ ! -d "$BUILD_DIR" ]; then
        echo "   ❌ Error: $BUILD_DIR does not exist. Run without --skip-build."
        exit 1
    fi
fi

# ── Step 2: Upload to VPS ─────────────────────────────────────
echo ""
echo "▶ [2/3] Syncing files to VPS..."
rsync -avz --delete \
    --exclude='.git' \
    --exclude='vercel.json' \
    --checksum \
    "$BUILD_DIR/" \
    "$VPS_USER@$VPS_IP:$REMOTE_WEB_ROOT/"

echo "   ✅ Files synced to $VPS_IP:$REMOTE_WEB_ROOT"

# ── Step 3: Reload Nginx ──────────────────────────────────────
echo ""
echo "▶ [3/3] Reloading Nginx..."
ssh "$VPS_USER@$VPS_IP" "sudo systemctl reload nginx"
echo "   ✅ Nginx reloaded."

# ── Done ─────────────────────────────────────────────────────
echo ""
echo "================================================================"
echo "  ✅  Deployment Complete!"
echo "  🌍  https://saborly.es"
echo "================================================================"
