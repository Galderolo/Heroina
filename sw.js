const CACHE_NAME = 'heroes-hogar-v4';
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
  const isCSSFile = url.pathname.endsWith('.css');
  const isJSONFile = url.pathname.endsWith('.json');
  const accept = event.request.headers.get('accept') || '';
  const isHTML = event.request.mode === 'navigate' || accept.includes('text/html');
  const isSameOrigin = url.origin === self.location.origin;

  // Normalizar clave de caché (ignoramos querystring tipo ?v=... o ?r=...).
  // Esto evita que el guard “cache-bust” genere entradas infinitas y, sobre todo,
  // permite reemplazar correctamente ./css/styles.css aunque se pida con querystring.
  const cacheKey = isSameOrigin ? new Request(url.origin + url.pathname, { method: 'GET' }) : event.request;
  
  // HTML: network-first (evita quedarse en HTML viejo cacheado)
  if (isHTML) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          if (response && response.status === 200) {
            const responseToCache = response.clone();
            caches.open(CACHE_NAME).then(cache => {
              cache.put(cacheKey, responseToCache);
            });
          }
          return response;
        })
        .catch(async () => {
          const cached = await caches.match(cacheKey);
          return cached || caches.match('./index.html');
        })
    );
    return;
  }

  // JS/CSS/JSON: network-first (para que módulos/estilos/manifest se actualicen)
  if (isJSFile || isCSSFile || isJSONFile) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          if (response.status === 200) {
            const responseToCache = response.clone();
            caches.open(CACHE_NAME).then(cache => {
              cache.put(cacheKey, responseToCache);
            });
          }
          return response;
        })
        .catch(() => {
          return caches.match(cacheKey);
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
