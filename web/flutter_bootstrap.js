{{flutter_js}}
{{flutter_build_config}}

// Flutter service worker explicitly disabled — prevents caching from blocking deployments.
// Push notifications still work via /firebase-messaging-sw.js registered in index.html.
// serviceWorkerVersion: null tells the Flutter loader to skip SW registration entirely.
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: null,
  },
});
