// Splash screen PWA estilo videojuego (ES Module)
// Muestra un overlay con barra de carga falsa solo en:
// - Modo standalone (PWA instalada)
// - Cold start (primer arranque del proceso: sessionStorage vacío)

import { detectStandalone } from './requirePwa.js';

const SESSION_KEY = 'pwa_splash_shown';

// Esperar a que el DOM esté completamente listo
function waitForDOMReady() {
  return new Promise((resolve) => {
    if (document.readyState === 'complete' || document.readyState === 'interactive') {
      // Usar requestAnimationFrame para asegurar que el renderizado esté completo
      requestAnimationFrame(() => {
        requestAnimationFrame(resolve);
      });
    } else {
      window.addEventListener('load', () => {
        requestAnimationFrame(() => {
          requestAnimationFrame(resolve);
        });
      }, { once: true });
    }
  });
}

// Esperar a que la imagen del banner se cargue
function waitForBannerImage(splashEl) {
  return new Promise((resolve) => {
    const bannerImg = splashEl.querySelector('.pwa-splash-banner');
    if (!bannerImg) {
      // Si no hay imagen, continuar inmediatamente
      resolve();
      return;
    }

    // Si la imagen ya está cargada
    if (bannerImg.complete && bannerImg.naturalHeight !== 0) {
      requestAnimationFrame(resolve);
      return;
    }

    // Esperar a que la imagen se cargue
    const onLoad = () => {
      requestAnimationFrame(resolve);
    };

    const onError = () => {
      // Si falla la carga, continuar de todas formas
      requestAnimationFrame(resolve);
    };

    bannerImg.addEventListener('load', onLoad, { once: true });
    bannerImg.addEventListener('error', onError, { once: true });

    // Timeout de seguridad: si la imagen tarda más de 3 segundos, continuar
    setTimeout(() => {
      requestAnimationFrame(resolve);
    }, 3000);
  });
}

export async function setupSplashScreen({ splashId = 'pwaSplash', durationMs = 2000 } = {}) {
  try {
    const isStandalone = detectStandalone?.() === true;
    if (!isStandalone) return; // Solo en PWA instalada

    const alreadyShown = sessionStorage.getItem(SESSION_KEY) === '1';
    if (alreadyShown) return; // Solo en cold start

    // Esperar a que el DOM esté listo
    await waitForDOMReady();

    const splashEl = document.getElementById(splashId);
    if (!splashEl) return;

    // Esperar a que la imagen se cargue
    await waitForBannerImage(splashEl);

    // Marcar como mostrado para esta sesión de proceso
    sessionStorage.setItem(SESSION_KEY, '1');

    // Mostrar splash encima de todo
    splashEl.classList.remove('pwa-splash-hidden');

    // Asegurar que el renderizado esté completo antes de iniciar el timer
    await new Promise((resolve) => {
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          resolve();
        });
      });
    });

    // Registrar el momento en que se muestra el splash
    const showTime = performance.now();

    // La barra tiene animación CSS de 2s; ocultamos el overlay al terminar
    setTimeout(() => {
      const elapsed = performance.now() - showTime;
      const remaining = Math.max(0, durationMs - elapsed);

      // Si ya pasaron los 2 segundos, ocultar inmediatamente
      // Si no, esperar el tiempo restante para garantizar mínimo 2 segundos
      if (remaining > 0) {
        setTimeout(() => {
          splashEl.classList.add('pwa-splash-hidden');
        }, remaining);
      } else {
        splashEl.classList.add('pwa-splash-hidden');
      }
    }, durationMs);
  } catch (error) {
    // Si algo falla, no bloqueamos la app
    console.error('Error en setupSplashScreen:', error);
  }
}

