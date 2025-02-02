'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "491d681d768bc9116ad6c207c99576c4",
"assets/AssetManifest.bin.json": "470b65e6004bd68c13e8cdd77d6f9080",
"assets/AssetManifest.json": "b89b76274605b2127e8546ad1e6b2340",
"assets/assets/images/logo.jpg": "40edae568ae82b5356f8faf5d7c93391",
"assets/assets/images/logo.png": "ce2df976b1cf923072e783cd190e2ce2",
"assets/assets/images/logoimage.jpg": "320456bc76b8f45b8a0877e84470f9f3",
"assets/assets/images/logoimage.png": "c7073a4cf1cd3340c54edc4f050b70aa",
"assets/assets/images/logoimage_midi.png": "4f45930a58b30e1aefd7fd1bc3633969",
"assets/assets/images/logoimage_mini.png": "6182ca39c12d5b5c7b2db02115d162e3",
"assets/FontManifest.json": "1b1e7812d9eb9f666db8444d7dde1b20",
"assets/fonts/MaterialIcons-Regular.otf": "6c7db60704aa43897ab506f5c1b72c65",
"assets/NOTICES": "1bd2493ca5dd0075689e5e7f29557b86",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/flutter_image_compress_web/assets/pica.min.js": "6208ed6419908c4b04382adc8a3053a2",
"assets/packages/material_design_icons_flutter/lib/fonts/materialdesignicons-webfont.ttf": "d10ac4ee5ebe8c8fff90505150ba2a76",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/staticwebapp.config.json": "f83ce68dca95b38899810ec1d6cff048",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.ico": "09319878a0f99501bb4fd18e4b19de92",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "9814a5ecd700f45b51b561b355d3c232",
"icons/android-icon-144x144.png": "5cb73f148e7d3bbbf537f32378a0ee9e",
"icons/android-icon-192x192.png": "e43adf764c0a279f67c81ab9acbc16ed",
"icons/android-icon-36x36.png": "b8af3c275df3c37f7e0dc91bc86999f0",
"icons/android-icon-48x48.png": "5be2d88124b57f7459351e375ff46fd1",
"icons/android-icon-72x72.png": "fe3a200c0e651eae7aa17f5e6c309e65",
"icons/android-icon-96x96.png": "cf8ab07f18557e8783e8a5cd60b77dad",
"icons/apple-icon-114x114.png": "27fcfcc9c04b7f24a20930ff46d44755",
"icons/apple-icon-120x120.png": "bbb0c9ffe0024c59c0a75abf0109509e",
"icons/apple-icon-144x144.png": "5cb73f148e7d3bbbf537f32378a0ee9e",
"icons/apple-icon-152x152.png": "4ca78a39568d366f9229df886ecc93ea",
"icons/apple-icon-180x180.png": "8f8c800ed7b4534c5e2d3b0b741828d8",
"icons/apple-icon-57x57.png": "f7b925832d5b973e55f00cf1af040b96",
"icons/apple-icon-60x60.png": "1311c150092086c56ae930819a788ed6",
"icons/apple-icon-72x72.png": "fe3a200c0e651eae7aa17f5e6c309e65",
"icons/apple-icon-76x76.png": "2ad815ac14b97f6f4636ece23e525f18",
"icons/apple-icon-precomposed.png": "a752a7bb83e23bfd614fab04418ec90b",
"icons/apple-icon.png": "a752a7bb83e23bfd614fab04418ec90b",
"icons/favicon-16x16.png": "ae483087bb3a69b861b25feca3c52e32",
"icons/favicon-32x32.png": "71d89610c88a03afa57a4d0f952457e1",
"icons/favicon-96x96.png": "cf8ab07f18557e8783e8a5cd60b77dad",
"icons/ms-icon-144x144.png": "5cb73f148e7d3bbbf537f32378a0ee9e",
"icons/ms-icon-150x150.png": "3afd9e2d7cd9786011bbf5682bfa296a",
"icons/ms-icon-310x310.png": "e902554af01d3a9a880e4e7b23b3d6d2",
"icons/ms-icon-70x70.png": "9c8a8eccfbe972844746097c7ba38f7f",
"index.html": "ecf81957f8d1a8cc4fb565e031aeb1ae",
"/": "ecf81957f8d1a8cc4fb565e031aeb1ae",
"main.dart.js": "e996c180e84cdd613f03d1cadae1b3bb",
"manifest.json": "47be4f623d9759e3ba047e4b64d4a445",
"version.json": "9e2906b3164e984ce54c0ee43a6b5e60"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
