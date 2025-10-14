// firebase-messaging-sw.js

// Import Firebase scripts (compat version for service worker support)
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

// --- 1. Default Firebase config (initial) ---
let firebaseConfig = {
  apiKey: 'AIzaSyBUPKovanIEvWa3oQtU3WP4jq8BMLKEzRg',
  authDomain: 'wydaccounts.firebaseapp.com',
  projectId: 'wydaccounts',
  storageBucket: 'wydaccounts.firebasestorage.app',
  messagingSenderId: '500769062162',
  appId: '1:500769062162:web:8c7933c946f0cf331247cb',
};

// --- 2. Initialize Firebase with default config ---
firebase.initializeApp(firebaseConfig);

// --- 3. Create messaging instance ---
let messaging = firebase.messaging();

// --- 4. Background message handler ---
function setupBackgroundHandler() {
  messaging.onBackgroundMessage((payload) => {
    // Log the full payload to inspect its structure
    console.log('Received data-only message in the background:', payload.data);

    // Get notification data from the 'data' payload
    const data = payload.data;
    const notificationTitle = data.title || 'Default Title';
    const notificationOptions = {
      body: data.body || '',
      icon: 'icons/favicon-96x96.png',
    };
    self.registration.showNotification(notificationTitle, notificationOptions);
  });
}

// Initial setup
setupBackgroundHandler();

/*
// --- 5. Listen for config updates from main thread ---
self.addEventListener('message', (event) => {
    if (event.data && event.data.type === 'UPDATE_FIREBASE_CONFIG') {
        try {
            // Update config
            firebaseConfig = event.data.config;

            // Re-initialize Firebase app
            firebase.initializeApp(firebaseConfig);

            // Recreate messaging instance
            messaging = firebase.messaging();

            // Re-attach background handler
            setupBackgroundHandler();

            console.log('[Service Worker] Firebase config updated successfully.');
        } catch (err) {
            console.error('[Service Worker] Failed to update Firebase config:', err);
        }
    }
});

*/

/*
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

Future<void> updateFirebaseConfigFromBackend() async {
  try {
    // 1. Request config from your backend
    final response = await http.get(Uri.parse('https://your-backend.com/firebase-config'));

    if (response.statusCode == 200) {
      final config = jsonDecode(response.body);

      // 2. Send config to service worker
      final sw = await html.window.navigator.serviceWorker?.ready;
      sw?.active?.postMessage({
        'type': 'UPDATE_FIREBASE_CONFIG',
        'config': config,
      });

      print('Firebase config sent to service worker.');
    } else {
      print('Failed to fetch Firebase config: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching Firebase config: $e');
  }
}
*/