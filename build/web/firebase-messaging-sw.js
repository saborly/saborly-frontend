// ---------------------------------------------------------------
// public/firebase-messaging-sw.js
// ---------------------------------------------------------------
// 1. Load the compat libraries (v9 – you are already using them)
importScripts(
  "https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js"
);

// 2. Your Firebase web config (copy-paste from Firebase console)
const firebaseConfig = {
 apiKey: "AIzaSyBnwI2qJNDW3CVNdf1_NidUMUrYTepqAxg",
  authDomain: "saborly-397b6.firebaseapp.com",
  projectId: "saborly-397b6",
  storageBucket: "saborly-397b6.firebasestorage.app",
  messagingSenderId: "420029681993",
  appId: "1:420029681993:web:4c0228b4b3c3efe1d68a98",
  measurementId: "G-6EWPX5Z5J9"
};

// 3. **Initialize the app inside the service worker**
firebase.initializeApp(firebaseConfig);

// 4. Get the messaging instance
const messaging = firebase.messaging();

// 5. Background message handler (required for FCM)
messaging.onBackgroundMessage = function (payload) {
  console.log("[firebase-messaging-sw.js] Background message:", payload);

  const notificationTitle = payload.notification?.title || "Saborly";
  const notificationOptions = {
    body: payload.notification?.body || "",
    icon: "/icon-192.png",          // <-- put your app icon in public/
    badge: "/badge-72.png",
    data: payload.data || {}
  };

  // Show the notification
  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
};

// 6. (Optional) Handle notification click → open your app
self.addEventListener("notificationclick", (event) => {
  event.notification.close();

  const url = "/"; // or any route you want, e.g. "/orders"
  event.waitUntil(
    clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then((clientList) => {
        // If a window is already open, focus it
        for (const client of clientList) {
          if (client.url === url && "focus" in client) {
            return client.focus();
          }
        }
        // Otherwise open a new one
        if (clients.openWindow) {
          return clients.openWindow(url);
        }
      })
  );
});