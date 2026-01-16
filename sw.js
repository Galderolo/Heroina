const CACHE_NAME = 'heroes-hogar-v1';
const urlsToCache = [
  '.',
  './index.html',
  './misiones.html',
  './tienda.html',
  './css/styles.css',
  './js/data.js',
  './js/storage.js',
  './js/game.js',
  './js/modals.js',
  './img/icon-192.svg',
  './img/icon-512.svg',
  './img/icon.svg'
];

// Instalación - cachear recursos
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Cache abierto');
        return cache.addAll(urlsToCache);
      })
  );
});

// Activación - limpiar cachés antiguas
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('Eliminando caché antigua:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Fetch - servir desde caché, fallback a red
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Cache hit - devolver respuesta
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
});
