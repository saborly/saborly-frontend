# ============================================================
#  Saborly — Flutter Web Build + Deploy (Windows PowerShell)
#  Usage: .\deployment\deploy.ps1 [-SkipBuild]
#
#  Requirements:
#    - Flutter SDK in PATH (run from a terminal where `flutter` works)
#    - SSH key-based access to VPS
# ============================================================
param(
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

function Assert-LastExitCode {
    param(
        [string]$StepName
    )
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: $StepName failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}

$VPS_USER   = "root"
$VPS_IP     = "161.97.151.182"
$REMOTE_ROOT = "/var/www/saborly"
$BUILD_DIR  = "build\web"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Saborly Deploy  ->  ${VPS_USER}@${VPS_IP}:${REMOTE_ROOT}/web" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# ── Step 1: Build ─────────────────────────────────────────
if (-not $SkipBuild) {
    Write-Host ""
    Write-Host "[1/3] Building Flutter web (release)..." -ForegroundColor Yellow
    flutter clean
    Assert-LastExitCode "flutter clean"

    flutter pub get
    Assert-LastExitCode "flutter pub get"

    # Use flags supported by this Flutter version.
    flutter build web --release --no-web-resources-cdn --pwa-strategy=none --no-wasm-dry-run
    Assert-LastExitCode "flutter build web"

    # ── Inject kill-switch service worker ─────────────────────────
    # Flutter generates a service worker that caches old files in users' browsers.
    # We replace it with a minimal "kill switch" SW that:
    #   1. Immediately takes over (skipWaiting)
    #   2. Deletes ALL old Flutter caches (flutter-app-cache, flutter-temp-cache, etc.)
    #   3. Claims all open tabs
    #   4. Has NO fetch handler → all requests go directly to nginx
    # The index.html unregister script then removes this kill-switch SW too.
    $killswitch = @'
'use strict';
// Saborly kill-switch service worker.
// Clears all stale Flutter caches so browsers always get fresh files from nginx.
self.addEventListener('install', function(e) {
  self.skipWaiting(); // Take over immediately, don't wait for old SW to be released
});
self.addEventListener('activate', function(e) {
  e.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(
        keys.filter(function(k) { return k.startsWith('flutter-'); })
            .map(function(k) { return caches.delete(k); })
      );
    }).then(function() {
      return self.clients.claim(); // Take control of all open tabs
    })
  );
});
// No fetch handler — all network requests pass through directly to nginx.
'@
    if (-not (Test-Path "build\web\flutter_service_worker.js")) {
        Write-Error "ERROR: Build output missing at build\\web. Aborting deploy."
        exit 1
    }
    Set-Content -Path "build\web\flutter_service_worker.js" -Value $killswitch -NoNewline
    Write-Host "   Kill-switch service worker injected." -ForegroundColor Gray
    Write-Host "   Build complete -> $BUILD_DIR\" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[1/3] Skipping build (-SkipBuild flag set)." -ForegroundColor Yellow
    if (-not (Test-Path $BUILD_DIR)) {
        Write-Error "ERROR: $BUILD_DIR does not exist. Run without -SkipBuild first."
        exit 1
    }
}

# ── Step 2: Upload nginx config ───────────────────────────
Write-Host ""
Write-Host "[2/3] Uploading files to VPS..." -ForegroundColor Yellow

# First clean the remote web directory so deleted files don't linger
ssh "${VPS_USER}@${VPS_IP}" "rm -rf ${REMOTE_ROOT}/web && mkdir -p ${REMOTE_ROOT}/web"

# Upload the build output  (scp copies build\web folder -> /var/www/saborly/web on server)
scp -r "$BUILD_DIR" "${VPS_USER}@${VPS_IP}:${REMOTE_ROOT}/"

# Upload latest nginx config and write to both filenames
# (sites-enabled symlink may point to either 'saborly' or 'saborly.conf')
scp "deployment\nginx\saborly.conf" "${VPS_USER}@${VPS_IP}:/etc/nginx/sites-available/saborly.conf"
ssh "${VPS_USER}@${VPS_IP}" "cp /etc/nginx/sites-available/saborly.conf /etc/nginx/sites-available/saborly"

# Fix ownership so nginx (www-data) can read the files
ssh "${VPS_USER}@${VPS_IP}" "chown -R www-data:www-data ${REMOTE_ROOT}/web && chmod -R 755 ${REMOTE_ROOT}/web"

Write-Host "   Files uploaded." -ForegroundColor Green

# ── Step 3: Reload nginx ──────────────────────────────────
Write-Host ""
Write-Host "[3/3] Reloading Nginx..." -ForegroundColor Yellow
ssh "${VPS_USER}@${VPS_IP}" "nginx -t && systemctl reload nginx"
Write-Host "   Nginx reloaded." -ForegroundColor Green

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Deployment Complete!  ->  https://saborly.es" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
