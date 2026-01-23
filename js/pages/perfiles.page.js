import '../version-check.js';
import { installGlobals } from '../compat/globals.js';
import { requirePwaOrRedirect } from '../ui/requirePwa.js';
import { installOrientationLock } from '../ui/orientationLock.js';
import { registerServiceWorker, setupPWAInstall } from '../ui/pwa.js';
import { setupSplashScreen } from '../ui/splashScreen.js';

(async () => {
  const whenReady = (fn) => {
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn, { once: true });
    else fn();
  };

  // Forzar PWA en móvil/tablet (no en localhost)
  const pwaGuard = requirePwaOrRedirect({ installPath: 'instalar.html' });
  if (pwaGuard.redirected) return;

  // No bloqueamos el render: el guard va en background
  window.runVersionGuard();

  installGlobals();
  setupPWAInstall();
  registerServiceWorker('./sw.js');
  installOrientationLock();

   // Splash estilo juego: solo PWA + cold start
   setupSplashScreen({ splashId: 'pwaSplash', durationMs: 2000 });

  function escapeHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function getDefaultAvatarSvg(label = '🙂') {
    const safe = encodeURIComponent(label);
    return `data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='96' height='96'%3E%3Crect width='96' height='96' rx='20' fill='%230f3460'/%3E%3Ctext x='50%25' y='55%25' font-size='44' text-anchor='middle' dy='.3em' fill='%23ffd700'%3E${safe}%3C/text%3E%3C/svg%3E`;
  }

  function renderProfiles(profiles) {
    const listEl = document.getElementById('profilesList');
    if (!listEl) return;

    if (!profiles || profiles.length === 0) {
      listEl.innerHTML = `
        <div class="col-12 text-center py-4" style="color:#a0a0a0;">
          <div style="font-size:2.2rem;">Perfil</div>
          <div class="mt-2">No hay perfiles todavía.</div>
          <div class="mt-1">Pulsa <strong>Crear perfil</strong> para empezar.</div>
        </div>
      `;
      return;
    }

    const activeId = window.storage.getActiveProfileId?.() || null;

    listEl.innerHTML = profiles
      .map((p) => {
        const name = p?.name && String(p.name).trim() ? String(p.name).trim() : 'Perfil sin nombre';
        const avatar = p?.avatar || getDefaultAvatarSvg('🙂');
        const isActive = activeId && p?.id === activeId;
        const hasHero = (p?.name || '').trim() !== '';
        const summary = hasHero ? window.storage.getProfileSummary?.(p.id) : null;
        const level = summary?.level || 1;
        const titleLine = summary?.displayTitle || '';

        return `
          <div class="col-12 col-md-6 col-lg-4 mb-3">
            <div class="card shadow-sm profile-card ${isActive ? 'is-active' : ''}" data-profile-id="${escapeHtml(p.id)}">
              <div class="card-body d-flex align-items-center gap-3 profile-card-body">
                <img src="${escapeHtml(avatar)}" alt="Avatar" class="profile-avatar" onerror="this.src='${getDefaultAvatarSvg('🙂')}'">
                <div class="flex-grow-1">
                  <div class="profile-name-line">
                    <div class="profile-name">${escapeHtml(name)}</div>
                    ${hasHero ? `<span class="profile-level-badge">Nivel ${escapeHtml(level)}</span>` : ``}
                  </div>
                  ${hasHero ? `<div class="profile-title-line">${escapeHtml(titleLine)}</div>` : ``}
                  <small class="profile-hint">${isActive ? 'Seleccionado' : 'Toca para jugar'}</small>
                </div>
                <button class="btn btn-sm btn-game-danger" data-action="delete" title="Borrar perfil">
                  <i class="bi bi-trash"></i>
                </button>
              </div>
            </div>
          </div>
        `;
      })
      .join('');
  }

  function goToIndex() {
    window.location.replace('index.html');
  }

  whenReady(() => {
    const params = new URLSearchParams(window.location.search);
    const manageMode = params.get('manage') === '1';

    const profiles = window.storage.listProfiles?.() || [];

    // Si solo existe 1 perfil, entramos directo SOLO si ya hay personaje creado (nombre no vacío).
    // Si está vacío, nos quedamos en la selección para que el usuario elija “Crear perfil”.
    if (!manageMode && profiles.length === 1 && (profiles[0]?.name || '').trim() !== '') {
      window.storage.setActiveProfile?.(profiles[0].id);
      goToIndex();
      return;
    }

    renderProfiles(profiles);

    const createBtn = document.getElementById('createProfileBtn');
    createBtn?.addEventListener('click', () => {
      // No crear perfil todavía: solo redirigir a creación
      // El perfil se creará cuando se complete la creación del personaje
      window.location.replace('index.html?create=1');
    });

    document.addEventListener('click', (e) => {
      const card = e.target?.closest?.('[data-profile-id]');
      if (!card) return;

      const profileId = card.getAttribute('data-profile-id');
      if (!profileId) return;

      const deleteBtn = e.target?.closest?.('[data-action="delete"]');
      if (deleteBtn) {
        window.showConfirm?.(
          '¿Seguro que quieres borrar este perfil? Esta acción no se puede deshacer.',
          '🗑️ Borrar perfil',
          () => {
            window.storage.deleteProfile?.(profileId);
            const updated = window.storage.listProfiles?.() || [];
            if (!manageMode && updated.length === 1) {
              window.storage.setActiveProfile?.(updated[0].id);
              goToIndex();
              return;
            }
            renderProfiles(updated);
          }
        );
        return;
      }

      window.storage.setActiveProfile?.(profileId);
      goToIndex();
    });
  });
})();

