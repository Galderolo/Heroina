import '../version-check.js';
import { installGlobals } from '../compat/globals.js';
import { registerServiceWorker, setupPWAInstall } from '../ui/pwa.js';
import { setupScrollToTop } from '../ui/scrollToTop.js';

(async () => {
  const whenReady = (fn) => {
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn, { once: true });
    else fn();
  };

  const deferVersionGuard = () => {
    const run = () => window.runVersionGuard();
    if (typeof window.requestIdleCallback === 'function') window.requestIdleCallback(run, { timeout: 2000 });
    else setTimeout(run, 500);
  };

  installGlobals();
  setupPWAInstall();
  registerServiceWorker('./sw.js');

  let misionSeleccionada = null;

  // Cache por render (evita recalcular/consultar en cada tarjeta)
  let cachedState = null;
  let cachedEnergy = 0;
  let cachedActiveMissions = [];
  let cachedHasMaxActive = false;

  function refreshRenderCache() {
    cachedState = window.game.getState();
    cachedEnergy = cachedState.character.energy || 0;
    cachedActiveMissions = window.game.getActiveMissions();
    cachedHasMaxActive = cachedActiveMissions && cachedActiveMissions.length >= 3;
  }

  function updateEnergyTimer() {
    const timerInfo = window.game.getEnergyTimerInfo();
    const timerElement = document.getElementById('headerEnergyTimer');
    if (!timerElement) return;

    if (timerInfo.isFull) {
      timerElement.style.display = 'none';
      return;
    }

    timerElement.style.display = 'block';
    const minutes = timerInfo.minutesRemaining;
    const seconds = timerInfo.secondsRemaining;

    if (minutes <= 0 && seconds <= 0) {
      const result = window.game.checkAndRestoreEnergy();
      if (result.restored) actualizarHeader();
      else updateEnergyTimer();
      return;
    }

    timerElement.textContent = minutes > 0 ? `⏱️ ${minutes}m ${seconds}s` : `⏱️ ${seconds}s`;
  }

  function actualizarHeader() {
    const summary = window.game.getCharacterSummary();
    const state = window.game.getState();
    const energy = state.character.energy || 0;
    const maxEnergy = state.character.maxEnergy || 6;
    const lives = state.character.lives !== undefined ? state.character.lives : 3;
    const maxLives = state.character.maxLives || 6;

    document.getElementById('headerNivel').textContent = summary.level;
    document.getElementById('headerEnergia').innerHTML = `${energy}/${maxEnergy} ⚡`;
    document.getElementById('headerVidas').innerHTML = `${lives}/${maxLives} ❤️`;
    document.getElementById('headerOro').innerHTML = `${summary.gold} <i class="bi bi-coin text-warning"></i>`;
    updateEnergyTimer();
  }

  function crearTarjetaMision(mission) {
    const colorClass = { diaria: 'border-success', ayuda: 'border-info', epica: 'border-warning' };

    const state = cachedState || window.game.getState();
    const currentEnergy = cachedState ? cachedEnergy : (state.character.energy || 0);
    const activeMissions = cachedState ? cachedActiveMissions : window.game.getActiveMissions();
    const isActive = activeMissions && activeMissions.some((m) => m.missionId === mission.id);
    const hasMaxActive = cachedState ? cachedHasMaxActive : (activeMissions && activeMissions.length >= 3);
    const noEnergy = currentEnergy < 1 && !isActive;

    let buttonHTML = '';
    let cardClass = '';

    if (isActive) {
      const activeMission = activeMissions.find((m) => m.missionId === mission.id);
      const hoursElapsed = (new Date() - new Date(activeMission.startDate)) / (1000 * 60 * 60);
      const hoursRemaining = 12 - hoursElapsed;

      let warningHTML = '';
      if (hoursRemaining <= 2 && hoursRemaining > 0) {
        warningHTML = `<div class="alert alert-danger alert-sm mb-2">
          <i class="bi bi-exclamation-triangle"></i> 
          ⚠️ Quedan ${Math.ceil(hoursRemaining)} horas o fracasará automáticamente
        </div>`;
      } else if (hoursRemaining <= 0) {
        warningHTML = `<div class="alert alert-danger alert-sm mb-2">
          <i class="bi bi-exclamation-triangle"></i> 
          ⚠️ Esta misión ha expirado y fracasará pronto
        </div>`;
      }

      cardClass = 'mision-en-progreso';
      buttonHTML = `
        ${warningHTML}
        <button class="btn btn-complete-mission w-100 mb-2" onclick="completarMisionDirecta(${mission.id})">
          <i class="bi bi-check-circle-fill"></i> ¡Completar!
        </button>
        <div class="row">
          <div class="col-6">
            <button class="btn btn-danger w-100 btn-sm" onclick="fracasarMision(${mission.id})">
              <i class="bi bi-x-circle-fill"></i> Fracasó (-1 ❤️)
            </button>
          </div>
          <div class="col-6">
            <button class="btn btn-outline-secondary w-100 btn-sm" onclick="cancelarMision(${mission.id})">
              <i class="bi bi-arrow-counterclockwise"></i> Cancelar
            </button>
          </div>
        </div>
      `;
    } else if (hasMaxActive) {
      cardClass = 'mision-deshabilitada';
      buttonHTML = `
        <button class="btn btn-secondary w-100" disabled>
          <i class="bi bi-lock"></i> Máximo de misiones alcanzado (3/3)
        </button>
      `;
    } else if (noEnergy) {
      cardClass = 'mision-deshabilitada';
      buttonHTML = `
        <button class="btn btn-secondary w-100" disabled>
          <i class="bi bi-lightning-charge"></i> Sin energía (necesitas 1 ⚡)
        </button>
      `;
    } else {
      buttonHTML = `
        <button class="btn btn-primary w-100" onclick="iniciarMision(${mission.id})">
          <i class="bi bi-play-fill"></i> Iniciar Misión (-1 ⚡)
        </button>
      `;
    }

    return `
      <div class="col-md-6 col-lg-4 mb-3 mision-item" data-tipo="${mission.type}">
        <div class="card h-100 mision-card ${colorClass[mission.type]} ${cardClass}">
          <div class="card-body">
            ${isActive ? '<div class="badge bg-warning text-dark mb-2"><i class="bi bi-hourglass-split"></i> En Progreso</div>' : ''}
            <div class="mision-icono mb-2">${mission.icon}</div>
            <h6 class="card-title fw-bold">${mission.name}</h6>
            <p class="card-text small" style="color: #a0a0a0;">${mission.description}</p>
            <div class="mision-recompensas mb-3">
              <span class="badge bg-primary me-2"><i class="bi bi-lightning-charge-fill"></i> 1 Energía</span>
              <span class="badge bg-info me-2"><i class="bi bi-star-fill"></i> ${mission.xp} XP</span>
              <span class="badge bg-warning"><i class="bi bi-coin"></i> ${mission.gold} Oro</span>
            </div>
            ${buttonHTML}
          </div>
        </div>
      </div>
    `;
  }

  function cargarMisiones() {
    const allMissions = window.game.getMissionsByType(null);
    const daily = allMissions.filter((m) => m.type === 'diaria');
    const help = allMissions.filter((m) => m.type === 'ayuda');
    const epic = allMissions.filter((m) => m.type === 'epica');

    document.getElementById('listaDiarias').innerHTML = daily.map(crearTarjetaMision).join('');
    document.getElementById('listaAyuda').innerHTML = help.map(crearTarjetaMision).join('');
    document.getElementById('listaEpicas').innerHTML = epic.map(crearTarjetaMision).join('');
  }

  // Firma nueva para no depender de `event` global
  window.filtrarMisiones = function filtrarMisiones(evt, tipo) {
    const sections = document.querySelectorAll('.misiones-seccion');
    const buttons = document.querySelectorAll('.btn-group .btn');

    buttons.forEach((btn) => btn.classList.remove('active'));
    evt?.target?.classList?.add('active');

    if (tipo === 'todas') {
      sections.forEach((s) => (s.style.display = 'block'));
    } else {
      sections.forEach((s) => (s.style.display = 'none'));
      if (tipo === 'diaria') document.getElementById('misionesDiarias').style.display = 'block';
      else if (tipo === 'ayuda') document.getElementById('misionesAyuda').style.display = 'block';
      else if (tipo === 'epica') document.getElementById('misionesEpicas').style.display = 'block';
    }
  };

  window.iniciarMision = function iniciarMision(missionId) {
    const result = window.game.startMission(missionId);
    if (!result.success) {
      window.showError(result.message);
      return;
    }
    refreshRenderCache();
    cargarMisiones();
    actualizarHeader();
  };

  window.cancelarMision = function cancelarMision(missionId) {
    window.showConfirm('No pierdes nada, pero tampoco ganas.', '¿Cancelar la misión?', () => {
      const result = window.game.cancelActiveMission(missionId);
      if (!result.success) {
        window.showError(result.message);
        return;
      }
      refreshRenderCache();
      cargarMisiones();
      actualizarHeader();
    });
  };

  window.fracasarMision = function fracasarMision(missionId) {
    window.showConfirm('Se perderá 1 vida ❤️ y 1 de energía ⚡', '⚠️ ¿Seguro que la misión FRACASÓ?', () => {
      const result = window.game.failActiveMission(missionId);
      if (!result.success) {
        window.showError(result.message);
        return;
      }

      if (result.noLives) window.showAlert('Has perdido una vida.\n\n⚠️ ¡NO QUEDAN VIDAS! Ten más cuidado.', '💔 ¡Misión fracasada!', '💔');
      else window.showAlert(`Has perdido una vida.\nVidas restantes: ${result.remainingLives}`, '💔 ¡Misión fracasada!', '💔');

      setTimeout(() => {
        refreshRenderCache();
        cargarMisiones();
        actualizarHeader();
      }, 500);
    });
  };

  window.completarMisionDirecta = function completarMisionDirecta(missionId) {
    const allMissions = window.game.getMissionsByType(null);
    const mission = allMissions.find((m) => m.id === missionId);
    misionSeleccionada = mission;
    document.getElementById('modalMisionNombre').textContent = mission.name;
    const modalEl = document.getElementById('modalConfirmacion');
    const modal = new window.bootstrap.Modal(modalEl);
    modal.show();
  };

  window.confirmarMision = function confirmarMision() {
    if (!misionSeleccionada) return;
    const result = window.game.completeActiveMission(misionSeleccionada.id);
    if (!result.success) {
      window.showError(result.message);
      return;
    }

    const modalConfirmacion = window.bootstrap.Modal.getInstance(document.getElementById('modalConfirmacion'));
    modalConfirmacion.hide();

    setTimeout(() => {
      window.showReward(result.xpGained, result.goldGained, result.leveledUp ? result : null, result.mission.icon, result.mission.name);
      if (result.leveledUp) {
        setTimeout(() => mostrarSubidaNivel(result), 2000);
      }
    }, 300);

    setTimeout(() => {
      refreshRenderCache();
      cargarMisiones();
      actualizarHeader();
    }, 500);

    misionSeleccionada = null;
  };

  function mostrarSubidaNivel(result) {
    document.getElementById('modalNuevoNivel').textContent = result.newLevel;
    document.getElementById('modalNuevoTitulo').textContent = result.title;
    const modal = new window.bootstrap.Modal(document.getElementById('modalSubidaNivel'));
    modal.show();

    if (typeof window.confetti === 'function') {
      window.confetti({
        particleCount: 200,
        spread: 100,
        origin: { y: 0.6 },
        colors: ['#FFD700', '#FFA500', '#FF8C00'],
      });
    }
  }

  whenReady(() => {
    // Bloquear acceso si no hay personaje (como antes)
    if (!window.game.validateCharacterExists()) return;

    const expired = window.game.checkExpiredMissions();
    if (expired.length > 0) {
      window.showError(
        `${expired.length} misión(es) han expirado después de 12 horas y han fracasado automáticamente. Se ha perdido 1 vida por cada una.`,
        '⚠️ Misiones Expiradas',
      );
    }

    refreshRenderCache();
    cargarMisiones();
    actualizarHeader();

    setInterval(() => updateEnergyTimer(), 1000);
    setInterval(() => {
      const result = window.game.checkAndRestoreEnergy();
      if (result.restored) {
        refreshRenderCache();
        actualizarHeader();
      }
      else updateEnergyTimer();
    }, 60000);

    setupScrollToTop();
    deferVersionGuard();
  });
})();

