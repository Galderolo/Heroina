import '../version-check.js';
import { installGlobals } from '../compat/globals.js';
import { registerServiceWorker, setupPWAInstall } from '../ui/pwa.js';
import { setupScrollToTop } from '../ui/scrollToTop.js';

(async () => {
  const whenReady = (fn) => {
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn, { once: true });
    else fn();
  };

  // No bloqueamos el render: el guard va en background
  window.runVersionGuard();

  installGlobals();
  setupPWAInstall();
  registerServiceWorker('./sw.js');

  // --- Funciones de la página (expuestas en window por los onclick existentes) ---
  function calcularTiempoTranscurrido(fechaInicio) {
    const ahora = new Date();
    const inicio = new Date(fechaInicio);
    const minutos = Math.floor((ahora - inicio) / 1000 / 60);

    if (minutos < 1) return 'unos momentos';
    if (minutos === 1) return '1 minuto';
    if (minutos < 60) return `${minutos} minutos`;

    const horas = Math.floor(minutos / 60);
    if (horas === 1) return '1 hora';
    return `${horas} horas`;
  }

  function calcularHorasTranscurridas(startDate) {
    const start = new Date(startDate);
    const now = new Date();
    return (now - start) / (1000 * 60 * 60);
  }

  function updateEnergyTimer() {
    const timerInfo = window.game.getEnergyTimerInfo();
    const timerElement = document.getElementById('energyTimer');
    if (!timerElement) return;

    if (timerInfo.isFull) {
      timerElement.style.display = 'none';
      return;
    }

    timerElement.style.display = 'inline-flex';
    const minutes = timerInfo.minutesRemaining;
    const seconds = timerInfo.secondsRemaining;

    if (minutes <= 0 && seconds <= 0) {
      const result = window.game.checkAndRestoreEnergy();
      if (result.restored) cargarPersonaje();
      else updateEnergyTimer();
      return;
    }

    const compactPortrait = window.matchMedia?.('(max-width: 576px) and (orientation: portrait)')?.matches;
    if (compactPortrait) {
      timerElement.textContent = minutes > 0 ? `⏱️ ${minutes}m ${seconds}s` : `⏱️ ${seconds}s`;
    } else {
      timerElement.textContent =
        minutes > 0 ? `⏱️ Próxima energía en: ${minutes}m ${seconds}s` : `⏱️ Próxima energía en: ${seconds}s`;
    }
  }

  function loadPotions() {
    const inventory = window.game.getPotionInventory();
    const potionsList = document.getElementById('potionsList');
    if (!potionsList) return;

    if (!inventory || inventory.length === 0) {
      potionsList.innerHTML =
        '<div class="col-12 text-center" style="color: #a0a0a0;"><p>No tienes pociones. ¡Cómpralas en la tienda!</p></div>';
      return;
    }

    const allRewards = window.data.getAllRewards(window.storage.getCustomRewards());

    potionsList.innerHTML = inventory
      .map((item) => {
        const potion = allRewards.find((r) => r.id === item.id);
        if (!potion) return '';
        return `
          <div class="col-md-4 mb-3">
            <div class="potion-card text-center">
              <div style="font-size: 3rem;">${potion.icon}</div>
              <h6 class="fw-bold mt-2">${potion.name}</h6>
              <p class="small mb-2" style="color: #a0a0a0;">${potion.description}</p>
              <p class="fw-bold mb-2">Cantidad: ${item.quantity}</p>
              <button class="btn btn-sm btn-primary w-100" onclick="usarPocion(${item.id})">
                <i class="bi bi-hand-index"></i> Usar
              </button>
            </div>
          </div>
        `;
      })
      .join('');
  }

  function cargarMisionesActivas() {
    const activeMissions = window.game.getActiveMissions();
    const container = document.getElementById('activeMissionsList');
    const section = document.getElementById('activeMissionSection');

    if (!container || !section) return;

    if (!activeMissions || activeMissions.length === 0) {
      section.style.display = 'none';
      return;
    }

    section.style.display = 'block';
    container.innerHTML = '';

    activeMissions.forEach((mission) => {
      const hoursElapsed = calcularHorasTranscurridas(mission.startDate);
      const hoursRemaining = 12 - hoursElapsed;

      const missionHTML = `
        <div class="mb-3 p-3 border rounded ${hoursRemaining <= 2 ? 'mission-warning-expiring' : ''}" style="background: rgba(22, 33, 62, 0.5);">
          <div class="d-flex align-items-center mb-2">
            <span style="font-size: 2rem; margin-right: 1rem;">${mission.icon}</span>
            <div class="flex-grow-1">
              <h6 class="mb-0" style="color: #e0e0e0;">${mission.name}</h6>
              <small style="color: #a0a0a0;">Iniciada hace ${calcularTiempoTranscurrido(mission.startDate)}</small>
              ${
                hoursRemaining <= 2 && hoursRemaining > 0
                  ? `<div class="mission-time-warning mt-1">⚠️ Quedan ${Math.ceil(hoursRemaining)} horas</div>`
                  : ''
              }
              ${hoursRemaining <= 0 ? `<div class="mission-time-warning mt-1">⚠️ Esta misión ha expirado</div>` : ''}
            </div>
          </div>
          <div class="d-grid gap-2">
            <button class="btn btn-complete-mission" onclick="completarMisionActiva(${mission.missionId})">
              <i class="bi bi-check-circle-fill"></i> Completar
            </button>
            <div class="btn-group">
              <button class="btn btn-danger btn-sm" onclick="fracasarMisionActiva(${mission.missionId})">
                <i class="bi bi-x-circle-fill"></i> Fracasó
              </button>
              <button class="btn btn-outline-secondary btn-sm" onclick="cancelarMisionActiva(${mission.missionId})">
                <i class="bi bi-arrow-counterclockwise"></i> Cancelar
              </button>
            </div>
          </div>
        </div>
      `;

      container.innerHTML += missionHTML;
    });
  }

  function mostrarSubidaNivel(result) {
    const modalEl = document.getElementById('modalSubidaNivel');
    if (!modalEl || !window.bootstrap?.Modal) return;

    const modal = new window.bootstrap.Modal(modalEl);
    document.getElementById('modalNuevoNivel').textContent = result.newLevel;
    document.getElementById('modalNuevoTitulo').textContent = result.title;
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

  function mostrarFracaso(result) {
    const remainingLives = result.remainingLives;
    if (result.noLives) window.showAlert('Has perdido una vida.\n\n⚠️ ¡NO QUEDAN VIDAS! Ten más cuidado.', '💔 ¡Misión fracasada!', '💔');
    else window.showAlert(`Has perdido una vida.\nVidas restantes: ${remainingLives}`, '💔 ¡Misión fracasada!', '💔');
  }

  function mostrarRecompensa(result) {
    window.showReward(result.xpGained, result.goldGained, result.leveledUp ? result : null, result.mission.icon, result.mission.name);
  }

  function cargarPersonaje() {
    const summary = window.game.getCharacterSummary();
    const state = window.game.getState();

    const nombrePersonaje = document.getElementById('nombrePersonaje');
    const tituloPersonaje = document.getElementById('tituloPersonaje');
    const nivelPersonaje = document.getElementById('nivelPersonaje');
    const barraXP = document.getElementById('barraXP');
    const textoXP = document.getElementById('textoXP');
    const oroPersonaje = document.getElementById('oroPersonaje');
    const energiaPersonaje = document.getElementById('energiaPersonaje');
    const vidasPersonaje = document.getElementById('vidasPersonaje');
    const avatarImage = document.getElementById('avatarImage');
    const misionesHoy = document.getElementById('misionesHoy');
    const xpHoy = document.getElementById('xpHoy');
    const oroHoy = document.getElementById('oroHoy');
    const rachaPersonaje = document.getElementById('rachaPersonaje');
    const totalMisiones = document.getElementById('totalMisiones');
    const totalXP = document.getElementById('totalXP');
    const totalOro = document.getElementById('totalOro');
    const totalGastado = document.getElementById('totalGastado');

    if (!nombrePersonaje) return;

    nombrePersonaje.textContent = summary.name;

    const classInfo = window.game.getCharacterClass();
    let titleText = summary.title;
    if (classInfo) titleText = `${classInfo.name} ${summary.title}`;
    if (tituloPersonaje) tituloPersonaje.innerHTML = `<i class="bi bi-award"></i> ${titleText}`;

    if (nivelPersonaje) nivelPersonaje.textContent = summary.level;

    const { currentXP, requiredXP, percentage } = summary.progress;
    if (barraXP) barraXP.style.width = `${percentage}%`;
    if (textoXP) textoXP.textContent = `${currentXP} / ${requiredXP} XP`;

    if (oroPersonaje) oroPersonaje.textContent = summary.gold;

    const energy = state.character.energy || 0;
    const maxEnergy = state.character.maxEnergy || 6;
    if (energiaPersonaje) energiaPersonaje.textContent = `${energy}/${maxEnergy}`;

    const lives = state.character.lives ?? 6;
    const maxLives = state.character.maxLives ?? 6;
    if (vidasPersonaje) vidasPersonaje.textContent = `${lives}/${maxLives} `;

    if (summary.avatar && avatarImage) avatarImage.src = summary.avatar;

    if (misionesHoy) misionesHoy.textContent = summary.todayStats.missions;
    if (xpHoy) xpHoy.textContent = summary.todayStats.xp;
    if (oroHoy) oroHoy.textContent = summary.todayStats.gold;
    if (rachaPersonaje) rachaPersonaje.textContent = summary.streak;

    if (totalMisiones) totalMisiones.textContent = state.stats.totalMissions;
    if (totalXP) totalXP.textContent = state.stats.totalXP;
    if (totalOro) totalOro.textContent = state.stats.totalGold;
    if (totalGastado) totalGastado.textContent = state.stats.totalSpent;

    cargarMisionesActivas();
    loadPotions();
    updateEnergyTimer();
  }

  // --- Handlers llamados desde HTML ---
  window.usarPocion = function usarPocion(potionId) {
    const result = window.game.usePotion(potionId);
    if (!result.success) {
      window.showError(result.message);
      return;
    }

    if (typeof window.confetti === 'function') {
      window.confetti({
        particleCount: 50,
        spread: 60,
        origin: { y: 0.6 },
        colors: ['#a855f7', '#8b5cf6', '#7c3aed'],
      });
    }

    window.showSuccess(result.message, '✨ ¡Poción Usada!');
    cargarPersonaje();
  };

  window.completarMisionActiva = function completarMisionActiva(missionId) {
    const result = window.game.completeActiveMission(missionId);
    if (!result.success) {
      window.showError(result.message);
      return;
    }

    mostrarRecompensa(result);
    if (result.leveledUp) {
      setTimeout(() => {
        mostrarSubidaNivel(result);
      }, 2000);
    }

    setTimeout(() => {
      cargarPersonaje();
    }, 500);
  };

  window.fracasarMisionActiva = function fracasarMisionActiva(missionId) {
    window.showConfirm('Se perderá 1 vida ❤️', '⚠️ ¿Seguro que la misión FRACASÓ?', () => {
      const result = window.game.failActiveMission(missionId);
      if (!result.success) {
        window.showError(result.message);
        return;
      }

      mostrarFracaso(result);
      setTimeout(() => cargarPersonaje(), 500);
    });
  };

  window.cancelarMisionActiva = function cancelarMisionActiva(missionId) {
    window.showConfirm('No pierdes nada, pero tampoco ganas.', '¿Cancelar la misión?', () => {
      window.game.cancelActiveMission(missionId);
      cargarPersonaje();
    });
  };

  window.cambiarNombre = function cambiarNombre() {
    const currentName = document.getElementById('nombrePersonaje')?.textContent || '';
    const newName = prompt('¿Cómo se llama tu heroína?', currentName);
    if (newName && newName.trim()) {
      window.game.configureCharacter(newName.trim());
      cargarPersonaje();
    }
  };

  window.cambiarAvatar = function cambiarAvatar() {
    document.getElementById('avatarInput')?.click();
  };

  window.cambiarPerfil = function cambiarPerfil() {
    window.location.href = 'perfiles.html?manage=1';
  };

  window.confirmarReinicio = function confirmarReinicio() {
    window.showConfirm('Esta acción NO se puede deshacer. Se borrará TODO el progreso.', '⚠️ Reiniciar Progreso', () => {
      window.game.resetGame();
      location.reload();
    });
  };

  // --- Creación de personaje ---
  let selectedGenderValue = '';
  let selectedClassValue = '';
  let creationAvatarBase64 = null;

  window.selectCreationAvatar = function selectCreationAvatar() {
    document.getElementById('creationAvatarInput')?.click();
  };

  window.selectGender = function selectGender(gender) {
    selectedGenderValue = gender;
    document.querySelectorAll('.gender-btn').forEach((btn) => btn.classList.remove('selected'));
    document.querySelector(`[data-gender="${gender}"]`)?.classList.add('selected');
  };

  window.selectClass = function selectClass(classId) {
    selectedClassValue = classId;
    document.querySelectorAll('.class-card').forEach((card) => card.classList.remove('selected'));
    document.querySelector(`[data-class="${classId}"]`)?.classList.add('selected');
  };

  function loadClassSelection() {
    const container = document.getElementById('classSelection');
    if (!container) return;
    const classes = window.data.CLASSES;

    container.innerHTML = classes
      .map(
        (cls) => `
          <div class="col-md-6 mb-3">
            <div class="class-card" data-class="${cls.id}" onclick="selectClass('${cls.id}')">
              <div class="class-icon">${cls.icon}</div>
              <h5 class="class-name">${cls.name}</h5>
              <p class="class-description">${cls.description}</p>
              <div class="class-stats">
                <span>❤️ ${cls.stats.lives}</span>
                <span>⚡ ${cls.stats.energy}</span>
              </div>
            </div>
          </div>
        `,
      )
      .join('');
  }

  window.finalizeCharacterCreation = function finalizeCharacterCreation() {
    const name = document.getElementById('heroName')?.value?.trim() || '';

    if (!name) {
      window.showError('Por favor, introduce tu nombre', 'Nombre Requerido');
      return;
    }
    if (!selectedGenderValue) {
      window.showError('Por favor, selecciona tu género', 'Género Requerido');
      return;
    }
    if (!selectedClassValue) {
      window.showError('Por favor, selecciona tu clase', 'Clase Requerida');
      return;
    }

    const result = window.storage.createCharacterWithClass(name, selectedGenderValue, selectedClassValue, creationAvatarBase64);

    if (result.success) {
      if (typeof window.confetti === 'function') {
        window.confetti({
          particleCount: 200,
          spread: 100,
          origin: { y: 0.6 },
          colors: ['#FFD700', '#FFA500', '#FF8C00'],
        });
      }

      sessionStorage.setItem('scrollToTopAfterReload', 'true');
      setTimeout(() => location.reload(), 100);
    } else {
      window.showError(result.message);
    }
  };

  function checkCharacterExists() {
    const state = window.game.getState();
    const characterExists = state.character.name && state.character.name !== '';

    const characterCreation = document.getElementById('characterCreation');
    const characterCard = document.getElementById('characterCard');
    const mainActions = document.getElementById('mainActions');
    const statsToday = document.getElementById('statsToday');
    const statsTotal = document.getElementById('statsTotal');
    const inventorySection = document.getElementById('inventory-section');

    if (!characterCreation || !characterCard || !statsToday || !statsTotal || !inventorySection) return;

    if (!characterExists) {
      characterCreation.style.display = 'block';
      characterCard.style.display = 'none';
      if (mainActions) mainActions.style.display = 'none';
      statsToday.style.display = 'none';
      statsTotal.style.display = 'none';
      inventorySection.style.display = 'none';
      loadClassSelection();
    } else {
      characterCreation.style.display = 'none';
      characterCard.style.display = 'block';
      if (mainActions) mainActions.style.display = 'block';
      statsToday.style.display = 'block';
      statsTotal.style.display = 'block';
      inventorySection.style.display = 'block';
    }
  }

  // Deshabilitar restauración automática del scroll del navegador
  if ('scrollRestoration' in history) {
    history.scrollRestoration = 'manual';
  }

  whenReady(async () => {
    // Mostrar loader para evitar “flash” de UI vacía
    const appLoader = document.getElementById('appLoader');
    appLoader?.classList.remove('is-hidden');

    // Guard de perfil activo: si no hay perfil seleccionado, volvemos a perfiles
    try {
      const activeId = window.storage.getActiveProfileId?.();
      if (!activeId) {
        const profiles = window.storage.listProfiles?.() || [];
        if (profiles.length === 1) {
          window.storage.setActiveProfile?.(profiles[0].id);
          window.game.initializeGame();
        } else {
          window.location.replace('perfiles.html');
          return;
        }
      }
    } catch (_) {
      // Si algo falla, mandamos a perfiles para evitar estados rotos
      window.location.replace('perfiles.html');
      return;
    }

    const shouldScrollToTop = sessionStorage.getItem('scrollToTopAfterReload') === 'true';
    if (shouldScrollToTop) window.scrollTo(0, 0);

    // Inputs de avatar
    document.getElementById('avatarInput')?.addEventListener('change', async (e) => {
      const file = e.target.files?.[0];
      if (!file) return;
      try {
        const avatarBase64 = await window.game.uploadAvatar(file);
        const avatarImage = document.getElementById('avatarImage');
        if (avatarImage) avatarImage.src = avatarBase64;
        window.showSuccess('¡Foto actualizada correctamente!');
      } catch (error) {
        window.showError(error?.message || 'Error al subir la imagen');
      }
    });

    document.getElementById('creationAvatarInput')?.addEventListener('change', async (e) => {
      const file = e.target.files?.[0];
      if (!file) return;
      try {
        const avatarBase64 = await window.game.uploadAvatar(file);
        const preview = document.getElementById('previewAvatar');
        if (preview) preview.src = avatarBase64;
        creationAvatarBase64 = avatarBase64;
      } catch (error) {
        window.showError(error?.message || 'Error al subir la imagen');
      }
    });

    checkCharacterExists();

    // Verificar misiones expiradas solo si hay misiones activas
    const activeMissions = window.game.getActiveMissions();
    if (activeMissions && activeMissions.length > 0) {
      const expired = window.game.checkExpiredMissions();
      if (expired.length > 0) {
        window.showError(
          `${expired.length} misión(es) han expirado después de 12 horas y han fracasado automáticamente. Se ha perdido 1 vida por cada una.`,
          '⚠️ Misiones Expiradas',
        );
      }
    }

    cargarPersonaje();

    // Ocultar loader tras el primer render
    requestAnimationFrame(() => {
      appLoader?.classList.add('is-hidden');
    });

    if (shouldScrollToTop) {
      requestAnimationFrame(() => {
        window.scrollTo(0, 0);
        setTimeout(() => {
          window.scrollTo(0, 0);
          sessionStorage.removeItem('scrollToTopAfterReload');
        }, 100);
      });

      window.addEventListener(
        'load',
        () => {
          window.scrollTo(0, 0);
        },
        { once: true },
      );
    }

    setTimeout(() => {
      setInterval(() => updateEnergyTimer(), 1000);
      setInterval(() => {
        const result = window.game.checkAndRestoreEnergy();
        if (result.restored) cargarPersonaje();
      }, 60000);
      setInterval(() => cargarMisionesActivas(), 60000);
    }, 100);

    setupScrollToTop();
  });
})();

