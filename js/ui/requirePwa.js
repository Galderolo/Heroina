// Forzar uso como PWA en móvil/tablet (ES Module)

export function detectStandalone() {
  return (
    window.matchMedia?.('(display-mode: standalone)')?.matches ||
    window.matchMedia?.('(display-mode: fullscreen)')?.matches ||
    window.navigator.standalone === true
  );
}

export function detectLocalDev() {
  const host = window.location.hostname;
  return host === 'localhost' || host === '127.0.0.1' || host === '0.0.0.0' || host === '::1';
}

export function detectMobileOrTablet() {
  const ua = navigator.userAgent || '';
  const uaMobile = /(Android|iPhone|iPad|iPod)/i.test(ua);

  // iPadOS moderno puede reportar UA tipo “Macintosh”; detectamos por plataforma + multitouch.
  // Esto cubre iPad Pro y tablets grandes sin depender de screen <= 1024.
  const platform = navigator.platform || '';
  const touch = Number(navigator.maxTouchPoints || 0) > 1;
  const isIpadOsDesktopUa = platform === 'MacIntel' && touch;

  return uaMobile || isIpadOsDesktopUa;
}

export function requirePwaOrRedirect({ installPath = 'instalar.html' } = {}) {
  try {
    if (detectLocalDev()) return { redirected: false, reason: 'localdev' };

    const isStandalone = detectStandalone();
    const isMobileOrTablet = detectMobileOrTablet();

    // Solo forzamos en móvil/tablet, y solo si NO está instalada.
    if (isMobileOrTablet && !isStandalone) {
      const current = window.location.pathname.split('/').pop() || '';
      if (current === installPath) return { redirected: false, reason: 'already_install_page' };
      window.location.replace(installPath);
      return { redirected: true, reason: 'require_pwa' };
    }
    return { redirected: false };
  } catch (e) {
    // Si falla detección, no bloqueamos.
    return { redirected: false, error: e };
  }
}

