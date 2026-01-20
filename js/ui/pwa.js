// PWA helpers (install button + service worker) (ES Module)

let deferredPrompt = null;

export function setupPWAInstall({ installNavItemId = 'installPWA', installButtonId = 'installButton' } = {}) {
  const installNavItem = document.getElementById(installNavItemId);
  const installButton = document.getElementById(installButtonId);

  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferredPrompt = e;
    if (installNavItem) installNavItem.style.display = 'block';
  });

  installButton?.addEventListener('click', async (e) => {
    e.preventDefault();
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    try {
      await deferredPrompt.userChoice;
    } finally {
      deferredPrompt = null;
      if (installNavItem) installNavItem.style.display = 'none';
    }
  });

  window.addEventListener('appinstalled', () => {
    if (installNavItem) installNavItem.style.display = 'none';
    deferredPrompt = null;
  });
}

export function registerServiceWorker(swPath = './sw.js') {
  if (!('serviceWorker' in navigator)) return;
  const host = window.location.hostname;
  const isLocalDev =
    host === 'localhost' ||
    host === '127.0.0.1' ||
    host === '0.0.0.0' ||
    host === '::1';

  window.addEventListener('load', () => {
    // En desarrollo (Live Server), desactivamos el SW para evitar cachés “pegajosas”.
    if (isLocalDev) {
      (async () => {
        try {
          const regs = await navigator.serviceWorker.getRegistrations();
          await Promise.all(regs.map((r) => r.unregister()));
        } catch (_) {
          // ignore
        }
        try {
          if ('caches' in window) {
            const names = await caches.keys();
            await Promise.all(names.map((n) => caches.delete(n)));
          }
        } catch (_) {
          // ignore
        }

        // Recargar una sola vez para aplicar cambios tras limpiar SW/cachés
        try {
          const key = 'heroina_dev_sw_cleared_once';
          if (sessionStorage.getItem(key) !== '1') {
            sessionStorage.setItem(key, '1');
            const url = new URL(window.location.href);
            url.searchParams.set('dev', String(Date.now()));
            window.location.replace(url.toString());
          }
        } catch (_) {
          // ignore
        }
      })();
      return;
    }

    navigator.serviceWorker
      .register(swPath)
      .then((registration) => {
        console.log('SW registrado:', registration.scope);
      })
      .catch((error) => {
        console.log('SW fallo:', error);
      });
  });
}

