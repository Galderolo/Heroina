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

  let recompensaSeleccionada = null;
  let rewardsCache = [];

  function actualizarHeader() {
    const summary = window.game.getCharacterSummary();
    const state = window.game.getState();
    const purchasedCount = state.history?.purchasedRewards?.length || 0;
    document.getElementById('headerNivel').textContent = summary.level;
    document.getElementById('headerOro').innerHTML = `${summary.gold} <i class="bi bi-coin text-warning"></i>`;
    document.getElementById('headerCompradas').textContent = purchasedCount;
  }

  function crearTarjetaRecompensa(reward) {
    const colorClass = {
      potion: 'border-purple',
      pequeña: 'border-success',
      media: 'border-info',
      grande: 'border-warning',
      epica: 'border-danger',
    };

    const locked = !reward.unlocked;
    const noGold = reward.unlocked && !reward.canPurchase;
    const hasCooldown = reward.cooldownHours && reward.cooldownHours > 0;
    let cooldownInfo = null;

    if (hasCooldown && !locked) cooldownInfo = window.game.getRewardCooldownInfo(reward.id);
    const onCooldown = cooldownInfo && cooldownInfo.onCooldown;

    let buttonHTML = '';
    let cooldownTimerHTML = '';

    if (locked) {
      buttonHTML = `
        <button class="btn btn-secondary w-100" disabled>
          <i class="bi bi-lock-fill"></i> Nivel ${reward.requiredLevel}
        </button>
      `;
    } else if (onCooldown) {
      const hours = cooldownInfo.hoursRemaining;
      const minutes = cooldownInfo.minutesRemaining;
      const seconds = cooldownInfo.secondsRemaining;
      const timerText =
        hours > 0 ? `⏱️ Disponible en: ${hours}h ${minutes}m` : minutes > 0 ? `⏱️ Disponible en: ${minutes}m ${seconds}s` : `⏱️ Disponible en: ${seconds}s`;

      buttonHTML = `
        <button class="btn btn-secondary w-100" disabled>
          <i class="bi bi-clock"></i> En Cooldown
        </button>
      `;
      cooldownTimerHTML = `
        <small id="cooldown-timer-${reward.id}" class="d-block mt-2" style="color: #a0a0a0; text-align: center;">
          ${timerText}
        </small>
      `;
    } else if (noGold) {
      buttonHTML = `
        <button class="btn btn-outline-warning w-100" disabled>
          <i class="bi bi-coin"></i> No tienes oro suficiente
        </button>
      `;
    } else {
      buttonHTML = `
        <button class="btn btn-warning w-100" onclick="prepararCompra(${reward.id})">
          <i class="bi bi-bag-check"></i> Comprar
        </button>
      `;
    }

    const cardClass = locked ? 'recompensa-bloqueada' : '';

    return `
      <div class="col-md-6 col-lg-4 mb-3 recompensa-item" data-categoria="${reward.category}" data-reward-id="${reward.id}">
        <div class="card h-100 recompensa-card ${colorClass[reward.category]} ${cardClass}">
          <div class="card-body">
            <div class="recompensa-icono mb-2">${reward.icon}</div>
            <h6 class="card-title fw-bold">${reward.name}</h6>
            <p class="card-text small" style="color: #a0a0a0;">${reward.description}</p>

            <div class="recompensa-precio mb-3">
              <span class="badge bg-warning text-dark fs-6">
                <i class="bi bi-coin"></i> ${reward.price} Oro
              </span>
              ${locked ? `<span class="badge bg-secondary ms-2"><i class="bi bi-lock"></i> Nivel ${reward.requiredLevel}</span>` : ''}
            </div>

            ${buttonHTML}
            ${cooldownTimerHTML}
          </div>
        </div>
      </div>
    `;
  }

  function cargarRecompensas() {
    rewardsCache = window.game.getAvailableRewards();

    const potions = rewardsCache.filter((r) => r.category === 'potion');
    const small = rewardsCache.filter((r) => r.category === 'pequeña');
    const medium = rewardsCache.filter((r) => r.category === 'media');
    const large = rewardsCache.filter((r) => r.category === 'grande');
    const epic = rewardsCache.filter((r) => r.category === 'epica');

    document.getElementById('listaPociones').innerHTML = potions.map(crearTarjetaRecompensa).join('');
    document.getElementById('listaPequenas').innerHTML = small.map(crearTarjetaRecompensa).join('');
    document.getElementById('listaMedias').innerHTML = medium.map(crearTarjetaRecompensa).join('');
    document.getElementById('listaGrandes').innerHTML = large.map(crearTarjetaRecompensa).join('');
    document.getElementById('listaEpicas').innerHTML = epic.map(crearTarjetaRecompensa).join('');
  }

  // Firma nueva para no depender de `event` global
  window.filtrarRecompensas = function filtrarRecompensas(evt, categoria) {
    const sections = document.querySelectorAll('.recompensas-seccion');
    const buttons = document.querySelectorAll('.btn-group .btn');

    buttons.forEach((btn) => btn.classList.remove('active'));
    evt?.target?.classList?.add('active');

    if (categoria === 'todas') {
      sections.forEach((s) => (s.style.display = 'block'));
    } else {
      sections.forEach((s) => (s.style.display = 'none'));
      if (categoria === 'potion') document.getElementById('recompensasPociones').style.display = 'block';
      else if (categoria === 'pequeña') document.getElementById('recompensasPequenas').style.display = 'block';
      else if (categoria === 'media') document.getElementById('recompensasMedias').style.display = 'block';
      else if (categoria === 'grande') document.getElementById('recompensasGrandes').style.display = 'block';
      else if (categoria === 'epica') document.getElementById('recompensasEpicas').style.display = 'block';
    }
  };

  window.prepararCompra = function prepararCompra(rewardId) {
    const reward = (rewardsCache && rewardsCache.length ? rewardsCache : window.game.getAvailableRewards()).find((r) => r.id === rewardId);
    recompensaSeleccionada = reward;

    document.getElementById('modalRecompensaIcono').textContent = reward.icon;
    document.getElementById('modalRecompensaNombre').textContent = reward.name;
    document.getElementById('modalRecompensaDescripcion').textContent = reward.description;
    document.getElementById('modalRecompensaPrecio').textContent = reward.price;

    const modal = new window.bootstrap.Modal(document.getElementById('modalConfirmacion'));
    modal.show();
  };

  window.confirmarCompra = function confirmarCompra() {
    if (!recompensaSeleccionada) return;

    let result;
    if (recompensaSeleccionada.category === 'potion') result = window.game.purchasePotion(recompensaSeleccionada.id);
    else result = window.game.purchaseReward(recompensaSeleccionada.id);

    const modalConfirmacion = window.bootstrap.Modal.getInstance(document.getElementById('modalConfirmacion'));
    modalConfirmacion.hide();

    if (result.success) {
      setTimeout(() => {
        const item = result.reward || result.potion;
        mostrarExito(item);
      }, 300);

      cargarRecompensas();
      actualizarHeader();
    } else {
      window.showError(result.message);
    }

    recompensaSeleccionada = null;
  };

  function mostrarExito(reward) {
    const state = window.game.getState();
    document.getElementById('modalExitoIcono').textContent = reward.icon;
    document.getElementById('modalExitoNombre').textContent = reward.name;
    document.getElementById('modalExitoOroRestante').textContent = `${state.character.gold} oro`;

    const modal = new window.bootstrap.Modal(document.getElementById('modalExito'));
    modal.show();

    if (typeof window.confetti === 'function') {
      window.confetti({
        particleCount: 150,
        spread: 80,
        origin: { y: 0.6 },
        colors: ['#FFD700', '#FFA500', '#FF6347'],
      });
    }
  }

  function updateRewardCooldowns() {
    const rewardsWithCooldown = (rewardsCache || []).filter((r) => r.cooldownHours && r.cooldownHours > 0);
    let needsReload = false;

    rewardsWithCooldown.forEach((reward) => {
      const timerElement = document.getElementById(`cooldown-timer-${reward.id}`);
      if (!timerElement) return;

      const cooldownInfo = window.game.getRewardCooldownInfo(reward.id);
      if (!cooldownInfo.onCooldown) {
        if (timerElement.style.display !== 'none') needsReload = true;
        return;
      }

      timerElement.style.display = 'block';
      const hours = cooldownInfo.hoursRemaining;
      const minutes = cooldownInfo.minutesRemaining;
      const seconds = cooldownInfo.secondsRemaining;
      const timerText =
        hours > 0 ? `⏱️ Disponible en: ${hours}h ${minutes}m` : minutes > 0 ? `⏱️ Disponible en: ${minutes}m ${seconds}s` : `⏱️ Disponible en: ${seconds}s`;

      timerElement.textContent = timerText;
    });

    if (needsReload) cargarRecompensas();
  }

  whenReady(() => {
    // Bloquear acceso si no hay personaje (como antes)
    if (!window.game.validateCharacterExists()) return;
    cargarRecompensas();
    actualizarHeader();
    setInterval(() => updateRewardCooldowns(), 1000);
    setupScrollToTop();
    deferVersionGuard();
  });
})();

