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
  './js/version-check.js',
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

self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  const isJSFile = url.pathname.endsWith('.js');
  
  if (isJSFile) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          if (response.status === 200) {
            const responseToCache = response.clone();
            caches.open(CACHE_NAME).then(cache => {
              cache.put(event.request, responseToCache);
            });
          }
          return response;
        })
        .catch(() => {
          return caches.match(event.request);
        })
    );
  } else {
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
  }
});
