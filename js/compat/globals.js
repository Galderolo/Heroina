// Capa de compatibilidad temporal: expone APIs mínimas en window
// (para que los atributos onclick existentes sigan funcionando)

import { data } from '../core/data.js';
import { game } from '../core/game.js';
import { storage } from '../infra/storage.js';
import { attachModalsToWindow } from '../ui/modals.js';
import { showWip } from '../ui/wip.js';

export function installGlobals() {
  attachModalsToWindow();
  window.showWip = showWip;

  // Mantener el API histórico (lo usan algunos scripts/plantillas antiguas).
  window.data = data;
  window.storage = storage;
  window.game = game;

  // Inicializar estado del juego.
  window.game.initializeGame();
}

