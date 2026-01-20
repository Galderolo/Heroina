import '../version-check.js';
import { installGlobals } from '../compat/globals.js';
import { registerServiceWorker, setupPWAInstall } from '../ui/pwa.js';

(async () => {
  const whenReady = (fn) => {
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn, { once: true });
    else fn();
  };

  const guardPromise = window.runVersionGuard();

  installGlobals();
  setupPWAInstall();
  registerServiceWorker('./sw.js');

  const AVAILABLE_ICONS = [
    '🛏️',
    '🧸',
    '🪥',
    '💧',
    '🏰',
    '🍳',
    '👗',
    '🚪',
    '🍎',
    '👨‍🍳',
    '🍽️',
    '🛒',
    '👕',
    '🗑️',
    '👟',
    '✨',
    '🛁',
    '💝',
    '🌟',
    '😊',
    '⏰',
    '🕊️',
    '📚',
    '🎨',
    '⚽',
    '🎮',
    '🧹',
    '🧼',
    '🥗',
    '🥛',
    '🧴',
    '📱',
    '💻',
    '📝',
    '✏️',
    '📷',
    '🎯',
    '🏆',
    '⭐',
    '💪',
    '🤝',
    '❤️',
    '🎁',
    '🎊',
    '🎈',
    '🍦',
    '📺',
    '🎵',
    '📖',
    '🎬',
    '🍿',
    '🎲',
    '🍪',
    '🎉',
    '🧁',
    '🛍️',
    '👑',
    '🍬',
    '🎪',
    '🎭',
    '🍕',
    '🍔',
    '🍟',
    '🍰',
    '🧋',
    '☕',
    '🎸',
    '🎹',
    '🎤',
    '🎧',
    '🖼️',
    '📸',
    '🎠',
    '🎡',
    '🎢',
    '🏖️',
    '🌳',
    '🚗',
  ];

  function renderIconGrid(containerId) {
    const container = document.getElementById(containerId);
    if (!container) return;
    container.innerHTML = AVAILABLE_ICONS.map((icon) => `<button type="button" class="icon-btn" data-icon="${icon}">${icon}</button>`).join('');
  }

  function setupIconSelectors() {
    document.getElementById('missionIconSelector')?.addEventListener('click', (e) => {
      const iconBtn = e.target.closest('.icon-btn');
      if (!iconBtn) return;
      e.preventDefault();
      e.stopPropagation();
      document.querySelectorAll('#missionIconSelector .icon-btn').forEach((btn) => btn.classList.remove('selected'));
      iconBtn.classList.add('selected');
      document.getElementById('missionIcon').value = iconBtn.dataset.icon;
    });

    document.getElementById('rewardIconSelector')?.addEventListener('click', (e) => {
      const iconBtn = e.target.closest('.icon-btn');
      if (!iconBtn) return;
      e.preventDefault();
      e.stopPropagation();
      document.querySelectorAll('#rewardIconSelector .icon-btn').forEach((btn) => btn.classList.remove('selected'));
      iconBtn.classList.add('selected');
      document.getElementById('rewardIcon').value = iconBtn.dataset.icon;
    });
  }

  function loadCustomMissions() {
    const missions = window.storage.getCustomMissions();
    const container = document.getElementById('customMissionsList');
    if (!container) return;

    if (!missions || missions.length === 0) {
      container.innerHTML =
        '<div class="col-12"><p class="text-muted text-center">No hay misiones personalizadas. Crea una nueva usando el formulario.</p></div>';
      return;
    }

    container.innerHTML = missions
      .map((mission) => {
        const typeLabels = { diaria: 'Diaria', ayuda: 'Ayuda', epica: 'Épica' };
        const typeColors = { diaria: 'success', ayuda: 'info', epica: 'warning' };

        return `
          <div class="col-md-6 mb-3">
            <div class="card border-${typeColors[mission.type]}">
              <div class="card-body">
                <div class="d-flex justify-content-between align-items-start mb-2">
                  <span class="badge bg-${typeColors[mission.type]}">${typeLabels[mission.type]}</span>
                  <div>
                    <button class="btn btn-sm btn-outline-primary" onclick="editMission(${mission.id})"><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-outline-danger" onclick="deleteMission(${mission.id})"><i class="bi bi-trash"></i></button>
                  </div>
                </div>
                <div class="text-center mb-2" style="font-size: 2rem;">${mission.icon}</div>
                <h6 class="fw-bold">${mission.name}</h6>
                <p class="small mb-2" style="color: #a0a0a0;">${mission.description}</p>
                <div class="small">
                  <span class="badge bg-info">${mission.xp} XP</span>
                  <span class="badge bg-warning">${mission.gold} Oro</span>
                </div>
              </div>
            </div>
          </div>
        `;
      })
      .join('');
  }

  function loadCustomRewards() {
    const rewards = window.storage.getCustomRewards();
    const container = document.getElementById('customRewardsList');
    if (!container) return;

    if (!rewards || rewards.length === 0) {
      container.innerHTML =
        '<div class="col-12"><p class="text-muted text-center">No hay recompensas personalizadas. Crea una nueva usando el formulario.</p></div>';
      return;
    }

    container.innerHTML = rewards
      .map((reward) => {
        const categoryLabels = { pequeña: 'Pequeña', media: 'Media', grande: 'Grande', epica: 'Épica' };
        const categoryColors = { pequeña: 'success', media: 'info', grande: 'warning', epica: 'danger' };

        return `
          <div class="col-md-6 mb-3">
            <div class="card border-${categoryColors[reward.category]}">
              <div class="card-body">
                <div class="d-flex justify-content-between align-items-start mb-2">
                  <span class="badge bg-${categoryColors[reward.category]}">${categoryLabels[reward.category]}</span>
                  <div>
                    <button class="btn btn-sm btn-outline-primary" onclick="editReward(${reward.id})"><i class="bi bi-pencil"></i></button>
                    <button class="btn btn-sm btn-outline-danger" onclick="deleteReward(${reward.id})"><i class="bi bi-trash"></i></button>
                  </div>
                </div>
                <div class="text-center mb-2" style="font-size: 2rem;">${reward.icon}</div>
                <h6 class="fw-bold">${reward.name}</h6>
                <p class="small mb-2" style="color: #a0a0a0;">${reward.description}</p>
                <div class="small">
                  <span class="badge bg-warning">${reward.price} Oro</span>
                </div>
              </div>
            </div>
          </div>
        `;
      })
      .join('');
  }

  window.editMission = function editMission(id) {
    const missions = window.storage.getCustomMissions();
    const mission = missions.find((m) => m.id === id);
    if (!mission) return;

    document.getElementById('missionName').value = mission.name;
    document.getElementById('missionDescription').value = mission.description;
    document.getElementById('missionType').value = mission.type;
    document.getElementById('missionIcon').value = mission.icon;
    document.getElementById('missionEditId').value = id;
    document.getElementById('missionSubmitBtn').innerHTML = '<i class="bi bi-check-circle"></i> Guardar Cambios';
    document.getElementById('missionCancelBtn').style.display = 'block';

    document.querySelectorAll('#missionIconSelector .icon-btn').forEach((btn) => {
      btn.classList.remove('selected');
      if (btn.dataset.icon === mission.icon) btn.classList.add('selected');
    });
  };

  window.cancelMissionEdit = function cancelMissionEdit() {
    document.getElementById('missionForm').reset();
    document.getElementById('missionEditId').value = '';
    document.getElementById('missionSubmitBtn').innerHTML = '<i class="bi bi-check-circle"></i> Crear Misión';
    document.getElementById('missionCancelBtn').style.display = 'none';
    document.querySelectorAll('#missionIconSelector .icon-btn').forEach((btn) => btn.classList.remove('selected'));
    document.getElementById('missionIcon').value = '';
  };

  window.deleteMission = function deleteMission(id) {
    window.showConfirm('Esta acción no se puede deshacer.', '¿Eliminar esta misión personalizada?', () => {
      window.storage.deleteCustomMission(id);
      loadCustomMissions();
      window.showSuccess('Misión eliminada correctamente');
    });
  };

  window.editReward = function editReward(id) {
    const rewards = window.storage.getCustomRewards();
    const reward = rewards.find((r) => r.id === id);
    if (!reward) return;

    document.getElementById('rewardName').value = reward.name;
    document.getElementById('rewardDescription').value = reward.description;
    document.getElementById('rewardCategory').value = reward.category;
    document.getElementById('rewardIcon').value = reward.icon;
    document.getElementById('rewardEditId').value = id;
    document.getElementById('rewardSubmitBtn').innerHTML = '<i class="bi bi-check-circle"></i> Guardar Cambios';
    document.getElementById('rewardCancelBtn').style.display = 'block';

    document.querySelectorAll('#rewardIconSelector .icon-btn').forEach((btn) => {
      btn.classList.remove('selected');
      if (btn.dataset.icon === reward.icon) btn.classList.add('selected');
    });
  };

  window.cancelRewardEdit = function cancelRewardEdit() {
    document.getElementById('rewardForm').reset();
    document.getElementById('rewardEditId').value = '';
    document.getElementById('rewardSubmitBtn').innerHTML = '<i class="bi bi-check-circle"></i> Crear Recompensa';
    document.getElementById('rewardCancelBtn').style.display = 'none';
    document.querySelectorAll('#rewardIconSelector .icon-btn').forEach((btn) => btn.classList.remove('selected'));
    document.getElementById('rewardIcon').value = '';
  };

  window.deleteReward = function deleteReward(id) {
    window.showConfirm('Esta acción no se puede deshacer.', '¿Eliminar esta recompensa personalizada?', () => {
      window.storage.deleteCustomReward(id);
      loadCustomRewards();
      window.showSuccess('Recompensa eliminada correctamente');
    });
  };

  whenReady(async () => {
    const { reloaded } = await guardPromise;
    if (reloaded) return;

    renderIconGrid('missionIconGrid');
    renderIconGrid('rewardIconGrid');
    setupIconSelectors();
    loadCustomMissions();
    loadCustomRewards();

    document.getElementById('missionForm')?.addEventListener('submit', (e) => {
      e.preventDefault();

      const name = document.getElementById('missionName').value.trim();
      const description = document.getElementById('missionDescription').value.trim();
      const type = document.getElementById('missionType').value;
      const icon = document.getElementById('missionIcon').value.trim();
      const editId = document.getElementById('missionEditId').value;

      if (!name || !description || !type || !icon) {
        window.showError('Por favor completa todos los campos');
        return;
      }

      const values = window.data.getStandardMissionValues(type);
      const mission = { name, description, type, icon, xp: values.xp, gold: values.gold, repeatable: true, custom: true };

      if (editId) {
        window.storage.updateCustomMission(Number(editId), mission);
        window.showSuccess('Misión actualizada correctamente');
      } else {
        window.storage.addCustomMission(mission);
        window.showSuccess('Misión creada correctamente');
      }

      window.cancelMissionEdit();
      loadCustomMissions();
    });

    document.getElementById('rewardForm')?.addEventListener('submit', (e) => {
      e.preventDefault();

      const name = document.getElementById('rewardName').value.trim();
      const description = document.getElementById('rewardDescription').value.trim();
      const category = document.getElementById('rewardCategory').value;
      const icon = document.getElementById('rewardIcon').value.trim();
      const editId = document.getElementById('rewardEditId').value;

      if (!name || !description || !icon) {
        window.showError('Por favor completa todos los campos');
        return;
      }

      const price = window.data.getStandardRewardPrice(category);
      const reward = { name, description, category, icon, price, requiredLevel: 1, custom: true };

      if (editId) {
        window.storage.updateCustomReward(Number(editId), reward);
        window.showSuccess('Recompensa actualizada correctamente');
      } else {
        window.storage.addCustomReward(reward);
        window.showSuccess('Recompensa creada correctamente');
      }

      window.cancelRewardEdit();
      loadCustomRewards();
    });
  });
})();

