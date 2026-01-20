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
  window.addEventListener('load', () => {
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

