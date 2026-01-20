// Acción genérica para secciones no implementadas (ES Module)

export function showWip() {
  if (typeof window.showInfo === 'function') {
    window.showInfo('Esta sección está en desarrollo.', 'WIP');
    return;
  }
  alert('Esta sección está en desarrollo.');
}

