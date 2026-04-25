{{flutter_js}}
{{flutter_build_config}}

// Flutter service worker explicitly disabled — prevents caching from blocking deployments.
// Push notifications still work via /firebase-messaging-sw.js registered in index.html.
// serviceWorkerVersion: null tells the Flutter loader to skip SW registration entirely.
_flutter.loader.load({
  // Force HTML renderer in production builds. This avoids CanvasKit/skwasm
  // incompatibilities caused by stale caches or hosting WASM MIME issues.
  renderer: "html",
  serviceWorkerSettings: {
    serviceWorkerVersion: null,
  },
});
