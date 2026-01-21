import '../version-check.js';
import { installGlobals } from '../compat/globals.js';
import { registerServiceWorker, setupPWAInstall } from '../ui/pwa.js';
import { detectMobileOrTablet } from '../ui/requirePwa.js';

(async () => {
  const whenReady = (fn) => {
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn, { once: true });
    else fn();
  };

  // No bloqueamos el render: el guard va en background
  window.runVersionGuard();

  installGlobals();
  setupPWAInstall();
  registerServiceWorker('./sw.js');

  const isStandalone =
    window.matchMedia?.('(display-mode: standalone)')?.matches ||
    window.matchMedia?.('(display-mode: fullscreen)')?.matches ||
    window.navigator.standalone === true;

  if (isStandalone) {
    window.location.replace('perfiles.html');
    return;
  }

  let deferredPrompt = null;

  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferredPrompt = e;
    const btn = document.getElementById('a2hsButton');
    const hint = document.getElementById('a2hsHint');
    if (hint) hint.textContent = 'Pulsa “Instalar” para añadir la app a tu pantalla de inicio.';
  });

  window.addEventListener('appinstalled', () => {
    window.location.replace('perfiles.html');
  });

  whenReady(() => {
    const btn = document.getElementById('a2hsButton');
    const hint = document.getElementById('a2hsHint');
    const enterWebCta = document.getElementById('enterWebCta');

    if (hint) {
      // iOS no dispara beforeinstallprompt; mostramos un mensaje útil por defecto.
      hint.textContent = 'Si el navegador no muestra el instalador, usa las instrucciones de abajo.';
    }

    // Desktop: esta página actúa como landing (SEO) y permite entrar a la web.
    const isMobile = detectMobileOrTablet();
    if (enterWebCta) enterWebCta.style.display = isMobile ? 'none' : 'block';

    btn?.addEventListener('click', async () => {
      if (!deferredPrompt) {
        window.showInfo?.('Sigue las instrucciones de abajo para instalar la app en tu dispositivo.', 'Instalación');
        return;
      }
      deferredPrompt.prompt();
      try {
        await deferredPrompt.userChoice;
      } finally {
        deferredPrompt = null;
      }
    });
  });
})();

