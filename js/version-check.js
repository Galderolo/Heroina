// Verificación de versiones para evitar caches “stale” en PWA
// Importante: este archivo debe funcionar tanto como script clásico (viejos caches)
// como cuando se carga desde ES Modules (side-effect import).

const FILES_TO_CHECK = [
  // HTML
  'index.html',
  'misiones.html',
  'tienda.html',
  'custom.html',
  // CSS/PWA
  'css/styles.css',
  'manifest.json',
  'sw.js',
  // Entrypoints de páginas
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

  try {
        const fetchPromises = filesToCheck.map(async (filePath) => {
      try {
        const url = `${filePath}?v=${Date.now()}`;
        const response = await fetch(url, {
          cache: 'no-store',
          headers: { 'Cache-Control': 'no-cache' },
        });

        if (!response.ok) {
          console.warn(`No se pudo cargar ${filePath}`);
                    // Si no podemos verificar un archivo, forzamos actualización (suele indicar caché stale o rutas rotas).
                    changedFiles.push(filePath);
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
                changedFiles.push(filePath);
        return null;
      }
    });

    await Promise.all(fetchPromises);

    for (const filePath of filesToCheck) {
      if (newVersions[filePath] && !storedVersions[filePath]) changedFiles.push(filePath);
    }

    return { needsUpdate: changedFiles.length > 0, changedFiles, newVersions };
  } catch (error) {
    console.error('Error al verificar versiones:', error);
    return { needsUpdate: false, changedFiles: [], newVersions: storedVersions };
  }
}

async function runVersionGuard(filesToCheck = FILES_TO_CHECK) {
  try {
    const guardKey = 'heroina_version_guard_reload_attempted';
    const lastCheckKey = 'heroina_version_guard_last_check';

    // No bloquear UX: no re-chequear constantemente en la misma sesión
    try {
      const last = Number(sessionStorage.getItem(lastCheckKey) || '0');
      const now = Date.now();
      // 5 min de “cooldown”
      if (last > 0 && now - last < 5 * 60 * 1000) {
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
      if (sessionStorage.getItem(guardKey) === '1') {
        return { reloaded: false };
      }
      sessionStorage.setItem(guardKey, '1');
    } catch (_) {
      // ignore
    }

    // Invalidar cache del service worker + caches
    if ('serviceWorker' in navigator) {
      const registrations = await navigator.serviceWorker.getRegistrations();
      for (const registration of registrations) {
        await registration.unregister();
      }
    }

    if ('caches' in window) {
      const cacheNames = await caches.keys();
      await Promise.all(cacheNames.map((name) => caches.delete(name)));
    }

    saveStoredFileVersions(versionCheck.newVersions);
    window.location.reload();
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
