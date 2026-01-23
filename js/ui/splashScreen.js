// Splash screen PWA estilo videojuego (ES Module)
// Muestra un overlay con barra de carga falsa solo en:
// - Modo standalone (PWA instalada)
// - Cold start (primer arranque del proceso: sessionStorage vacío)

import { detectStandalone } from './requirePwa.js';

const SESSION_KEY = 'pwa_splash_shown';

export function setupSplashScreen({ splashId = 'pwaSplash', durationMs = 2000 } = {}) {
  try {
    const isStandalone = detectStandalone?.() === true;
    if (!isStandalone) return; // Solo en PWA instalada

    const alreadyShown = sessionStorage.getItem(SESSION_KEY) === '1';
    if (alreadyShown) return; // Solo en cold start

    const splashEl = document.getElementById(splashId);
    if (!splashEl) return;

    // Marcar como mostrado para esta sesión de proceso
    sessionStorage.setItem(SESSION_KEY, '1');

    // Mostrar splash encima de todo
    splashEl.classList.remove('pwa-splash-hidden');

    // La barra tiene animación CSS de 2s; ocultamos el overlay al terminar
    setTimeout(() => {
      splashEl.classList.add('pwa-splash-hidden');
    }, durationMs);
  } catch (error) {
    // Si algo falla, no bloqueamos la app
    console.error('Error en setupSplashScreen:', error);
  }
}

