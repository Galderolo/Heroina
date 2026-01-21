// Forzar orientación vertical en PWA instalada (ES Module)

function detectStandalone() {
  return (
    window.matchMedia?.('(display-mode: standalone)')?.matches ||
    window.matchMedia?.('(display-mode: fullscreen)')?.matches ||
    window.navigator.standalone === true
  );
}

function ensureOverlay() {
  let el = document.getElementById('orientationOverlay');
  if (el) return el;

  el = document.createElement('div');
  el.id = 'orientationOverlay';
  el.className = 'orientation-overlay is-hidden';
  el.innerHTML = `
    <div class="orientation-overlay-panel">
      <div class="orientation-overlay-icon">📱</div>
      <div class="fantasy-font orientation-overlay-title">Modo vertical</div>
      <div class="orientation-overlay-subtitle">Gira el dispositivo para volver a vertical</div>
    </div>
  `;
  document.body.appendChild(el);
  return el;
}

function setOverlayVisible(visible) {
  const el = ensureOverlay();
  el.classList.toggle('is-hidden', !visible);
}

export function installOrientationLock() {
  try {
    if (!detectStandalone()) return { enabled: false, reason: 'not_standalone' };

    // Intento best-effort: algunos navegadores requieren gesto del usuario
    const lockFn = window.screen?.orientation?.lock;
    if (typeof lockFn === 'function') {
      lockFn.call(window.screen.orientation, 'portrait').catch(() => {
        // ignore
      });
    }

    const mq = window.matchMedia?.('(orientation: landscape)');
    const update = () => {
      const isLandscape = mq ? mq.matches : (window.innerWidth > window.innerHeight);
      setOverlayVisible(isLandscape);
    };

    update();
    mq?.addEventListener?.('change', update);
    window.addEventListener('resize', update);

    return { enabled: true };
  } catch (e) {
    return { enabled: false, error: e };
  }
}

