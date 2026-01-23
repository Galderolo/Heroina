// Página splash screen - redirige inmediatamente
// El splash se oculta visualmente después de 2 segundos (manejado por script inline)
import '../version-check.js';
import { installGlobals } from '../compat/globals.js';
import { registerServiceWorker } from '../ui/pwa.js';

(async () => {
  try {
    installGlobals();
    registerServiceWorker('./sw.js');

    // Redirigir inmediatamente - el splash visual se oculta después de 2 segundos
    redirectToDestination();
  } catch (error) {
    console.error('[SPLASH] Error:', error);
    // Si algo falla, intentar redirigir de todas formas
    redirectToDestination();
  }
})();

function redirectToDestination() {
  try {
    // Verificar si hay perfil activo
    const activeId = window.storage?.getActiveProfileId?.();
    
    if (activeId) {
      window.location.replace('personaje.html');
    } else {
      window.location.replace('perfiles.html');
    }
  } catch (error) {
    console.error('[SPLASH] Error al determinar destino:', error);
    window.location.replace('perfiles.html');
  }
}
