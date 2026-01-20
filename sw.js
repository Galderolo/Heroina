const CACHE_NAME = 'heroes-hogar-v3';
const urlsToCache = [
  '.',
  './index.html',
  './misiones.html',
  './tienda.html',
  './custom.html',
  './css/styles.css',
  './manifest.json',

  // Entrypoints ES Modules (páginas)
  './js/pages/index.page.js',
  './js/pages/misiones.page.js',
  './js/pages/tienda.page.js',
  './js/pages/custom.page.js',

  // Módulos compartidos
  './js/compat/globals.js',
  './js/core/data.js',
  './js/core/game.js',
  './js/infra/storage.js',
  './js/ui/modals.js',
  './js/ui/pwa.js',
  './js/ui/scrollToTop.js',
  './js/ui/wip.js',
  './js/version-check.js',

  './img/icon-192.svg',
  './img/icon-512.svg',
  './img/icon.svg',
];

// Instalación - cachear recursos
self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    console.log('Cache abierto');
    await cache.addAll(urlsToCache);
    // Activar el nuevo SW sin esperar a cerrar pestañas
    await self.skipWaiting();
  })());
});

// Activación - limpiar cachés antiguas
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const cacheNames = await caches.keys();
    await Promise.all(
      cacheNames.map(cacheName => {
        if (cacheName !== CACHE_NAME) {
          console.log('Eliminando caché antigua:', cacheName);
          return caches.delete(cacheName);
        }
      })
    );
    // Tomar control inmediato de las páginas abiertas
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  const isJSFile = url.pathname.endsWith('.js');
  const accept = event.request.headers.get('accept') || '';
  const isHTML = event.request.mode === 'navigate' || accept.includes('text/html');
  
  // HTML: network-first (evita quedarse en HTML viejo cacheado)
  if (isHTML) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          if (response && response.status === 200) {
            const responseToCache = response.clone();
            caches.open(CACHE_NAME).then(cache => {
              cache.put(event.request, responseToCache);
            });
          }
          return response;
        })
        .catch(async () => {
          const cached = await caches.match(event.request);
          return cached || caches.match('./index.html');
        })
    );
    return;
  }

  // JS: network-first (para que los módulos se actualicen)
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
    // Resto: cache-first (estáticos)
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
