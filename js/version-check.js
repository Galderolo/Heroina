// Verificación de versiones para evitar caches “stale” en PWA
// Importante: este archivo debe funcionar tanto como script clásico (viejos caches)
// como cuando se carga desde ES Modules (side-effect import).

const FILES_TO_CHECK = [
  // HTML
  'instalar.html',
  'perfiles.html',
  'index.html',
  'misiones.html',
  'tienda.html',
  'custom.html',
  // CSS/PWA
  'css/styles.css',
  'manifest.json',
  'sw.js',
  // Entrypoints de páginas
  'js/pages/instalar.page.js',
  'js/pages/perfiles.page.js',
  'js/pages/index.page.js',
  'js/pages/misiones.page.js',
  'js/pages/tienda.page.js',
  'js/pages/custom.page.js',
  // Módulos base
  'js/core/data.js',
  'js/core/game.js',
  'js/infra/storage.js',
  'js/ui/modals.js',
  'js/ui/pwa.js',
  'js/ui/requirePwa.js',
  'js/ui/orientationLock.js',
  'js/ui/scrollToTop.js',
  'js/ui/wip.js',
  // Este mismo archivo
  'js/version-check.js',
];

function calculateFileHash(content) {
  let hash = 0;
  const length = content.length;
  for (let i = 0; i < content.length; i++) {
    const char = content.charCodeAt(i);
    hash = (hash << 5) - hash + char;
    hash = hash & hash; // 32-bit
  }
  return `${length}-${Math.abs(hash).toString(36)}`;
}

function getStoredFileVersions() {
  try {
    const versions = localStorage.getItem('app_file_versions');
    return versions ? JSON.parse(versions) : {};
  } catch (error) {
    console.error('Error getting file versions:', error);
    return {};
  }
}

function saveStoredFileVersions(versions) {
  try {
    localStorage.setItem('app_file_versions', JSON.stringify(versions));
    return true;
  } catch (error) {
    console.error('Error saving file versions:', error);
    return false;
  }
}

async function checkFilesVersion(filesToCheck = FILES_TO_CHECK) {
  const storedVersions = getStoredFileVersions();
  const newVersions = {};
  const changedFiles = [];
  const hasBaseline = storedVersions && Object.keys(storedVersions).length > 0;

  try {
        const fetchPromises = filesToCheck.map(async (filePath) => {
      try {
        // Nota: usamos no-store para saltarnos caché HTTP.
        // (Si hay SW, el comportamiento final depende de su estrategia de fetch.)
        // Añadimos cache-bust para saltarnos caches del SW (si usa cache-first).
        const url = `${filePath}?v=${Date.now()}`;
        const response = await fetch(url, {
          cache: 'no-store',
          headers: { 'Cache-Control': 'no-cache' },
        });

        if (!response.ok) {
          console.warn(`No se pudo cargar ${filePath}`);
          // Solo forzamos update si ya teníamos baseline previo (evita reload en el primer arranque).
          if (hasBaseline && storedVersions[filePath]) changedFiles.push(filePath);
          return null;
        }

        const content = await response.text();
        const hash = calculateFileHash(content);
        newVersions[filePath] = hash;

        if (storedVersions[filePath] && storedVersions[filePath] !== hash) changedFiles.push(filePath);
        return { filePath, hash, changed: storedVersions[filePath] !== hash };
      } catch (error) {
        console.error(`Error al verificar ${filePath}:`, error);
        if (storedVersions[filePath]) newVersions[filePath] = storedVersions[filePath];
        if (hasBaseline && storedVersions[filePath]) changedFiles.push(filePath);
        return null;
      }
    });

    await Promise.all(fetchPromises);

    return { needsUpdate: changedFiles.length > 0, changedFiles, newVersions };
  } catch (error) {
    console.error('Error al verificar versiones:', error);
    return { needsUpdate: false, changedFiles: [], newVersions: storedVersions };
  }
}

async function runVersionGuard(filesToCheck = FILES_TO_CHECK) {
  try {
    const lastCheckKey = 'heroina_version_guard_last_check';
    const lastReloadKey = 'heroina_version_guard_last_reload';

    // Si estamos offline, no intentamos “arreglar” caches.
    if (typeof navigator !== 'undefined' && navigator && navigator.onLine === false) {
      return { reloaded: false, skipped: true, reason: 'offline' };
    }

    // No bloquear UX: evitamos chequear varias veces seguidas en la misma sesión,
    // pero el cooldown debe ser corto para que en desarrollo se actualice “al tirón”.
    try {
      const last = Number(sessionStorage.getItem(lastCheckKey) || '0');
      const now = Date.now();
      // 10s de “cooldown”
      if (last > 0 && now - last < 10 * 1000) {
        return { reloaded: false, skipped: true };
      }
      sessionStorage.setItem(lastCheckKey, String(now));
    } catch (_) {
      // ignore
    }

    const versionCheck = await checkFilesVersion(filesToCheck);
    if (!versionCheck.needsUpdate) {
      saveStoredFileVersions(versionCheck.newVersions);
      return { reloaded: false };
    }

    // Evitar bucles de recarga si hay problemas de red/offline
    try {
      const lastReload = Number(sessionStorage.getItem(lastReloadKey) || '0');
      const now = Date.now();
      // No recargar más de 1 vez cada 15s en la misma pestaña (pero permite siguientes updates)
      if (lastReload > 0 && now - lastReload < 15 * 1000) return { reloaded: false, throttled: true };
      sessionStorage.setItem(lastReloadKey, String(now));
    } catch (_) {
      // ignore
    }

    // Forzar a que el SW (si existe) se actualice, y limpiar caches.
    try {
      if ('serviceWorker' in navigator) {
        const registrations = await navigator.serviceWorker.getRegistrations();
        await Promise.all(registrations.map((r) => r.update?.()));
      }
    } catch (_) {
      // ignore
    }

    try {
      if ('caches' in window) {
        const cacheNames = await caches.keys();
        await Promise.all(cacheNames.map((name) => caches.delete(name)));
      }
    } catch (_) {
      // ignore
    }

    saveStoredFileVersions(versionCheck.newVersions);
    // “Hard reload” con cache-bust en la URL (evita quedarse en HTML/CSS antiguos)
    const url = new URL(window.location.href);
    url.searchParams.set('r', String(Date.now()));
    window.location.replace(url.toString());
    return { reloaded: true };
  } catch (error) {
    console.error('Error en verificación de versión:', error);
    return { reloaded: false };
  }
}

// Exponer en window para compatibilidad con versiones antiguas
if (typeof window !== 'undefined') {
  window.FILES_TO_CHECK = FILES_TO_CHECK;
  window.calculateFileHash = calculateFileHash;
  window.getStoredFileVersions = getStoredFileVersions;
  window.saveStoredFileVersions = saveStoredFileVersions;
  window.checkFilesVersion = checkFilesVersion;
  window.runVersionGuard = runVersionGuard;
}
