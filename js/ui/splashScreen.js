// Splash screen PWA estilo videojuego (ES Module)
// Muestra un overlay con barra de carga falsa solo en:
// - Modo standalone (PWA instalada)
// - Cold start (primer arranque del proceso: sessionStorage vacío)

import { detectStandalone } from './requirePwa.js';

const SESSION_KEY = 'pwa_splash_shown';

export function setupSplashScreen({ splashId = 'pwaSplash', durationMs = 2000 } = {}) {
  try {
    const isStandalone = detectStandalone?.() === true;
    if (!isStandalone) {
      // No es PWA: asegurar que el body esté visible
      document.body.classList.remove('body-hidden-during-splash');
      return;
    }

    const alreadyShown = sessionStorage.getItem(SESSION_KEY) === '1';
    if (alreadyShown) {
      // Ya se mostró: asegurar que el body esté visible
      document.body.classList.remove('body-hidden-during-splash');
      return;
    }

    const splashEl = document.getElementById(splashId);
    if (!splashEl) {
      document.body.classList.remove('body-hidden-during-splash');
      return;
    }

    // Marcar como mostrado para esta sesión de proceso
    sessionStorage.setItem(SESSION_KEY, '1');

    // Mostrar splash encima de todo (el script inline ya lo hizo, pero por si acaso)
    splashEl.classList.remove('pwa-splash-hidden');
    document.body.classList.add('body-hidden-during-splash');

    // La barra tiene animación CSS de 2s; ocultamos el overlay al terminar
    setTimeout(() => {
      splashEl.classList.add('pwa-splash-hidden');
      // Mostrar el body cuando se oculta el splash
      document.body.classList.remove('body-hidden-during-splash');
    }, durationMs);
  } catch (error) {
    // Si algo falla, no bloqueamos la app pero mostramos el body
    document.body.classList.remove('body-hidden-during-splash');
    console.error('Error en setupSplashScreen:', error);
  }
}

