// Motor/casos de uso del juego (ES Module)

import {
  CLASSES,
  REWARDS,
  calculateXPForLevel,
  getTitleByLevel,
  getAllMissions,
  getAllRewards,
} from './data.js';
import * as storageApi from '../infra/storage.js';

let gameState = null;

function initializeGame() {
  gameState = storageApi.loadData();
  return gameState;
}

function getState() {
  if (!gameState) initializeGame();
  return gameState;
}

function configureCharacter(name, avatarBase64 = null) {
  storageApi.updateCharacter('name', name);
  if (avatarBase64) storageApi.updateCharacter('avatar', avatarBase64);
  gameState = storageApi.loadData();
  return gameState;
}

function getAllMissionsResolved() {
  const custom = storageApi.getCustomMissions();
  return getAllMissions(custom);
}

function getAllRewardsResolved() {
  const custom = storageApi.getCustomRewards();
  return getAllRewards(custom);
}

function startMission(missionId) {
  const allMissions = getAllMissionsResolved();
  const mission = allMissions.find((m) => m.id === missionId);

  if (!mission) return { success: false, message: 'Misión no encontrada' };

  if (!storageApi.hasEnoughEnergy()) {
    return {
      success: false,
      message: 'No tienes suficiente energía (necesitas 1 ⚡). Espera a mañana, sube de nivel o usa una poción.',
    };
  }

  const result = storageApi.startMission(missionId, mission.name, mission.icon);
  if (!result.success) return result;

  gameState = storageApi.loadData();

  return { success: true, mission, message: 'Misión iniciada' };
}

function cancelActiveMission(missionId) {
  const result = storageApi.cancelActiveMission(missionId);
  gameState = storageApi.loadData();
  return result;
}

function getActiveMissions() {
  return storageApi.getActiveMissions();
}

function completeActiveMission(missionId) {
  const activeMissions = storageApi.getActiveMissions();
  const missionIdNum = Number(missionId);
  const activeMission = activeMissions.find((m) => Number(m.missionId) === missionIdNum);
  if (!activeMission) return { success: false, message: 'Misión no encontrada' };

  const allMissions = getAllMissionsResolved();
  const mission = allMissions.find((m) => m.id === missionIdNum);
  if (!mission) return { success: false, message: 'Misión no encontrada' };

  storageApi.completeActiveMission(missionId);
  const result = storageApi.registerCompletedMission(mission.id, mission.xp, mission.gold);
  gameState = storageApi.loadData();

  return {
    success: true,
    type: 'completed',
    mission,
    xpGained: mission.xp,
    goldGained: mission.gold,
    leveledUp: result.leveledUp,
    newLevel: result.newLevel,
    title: result.title,
  };
}

function checkExpiredMissions() {
  return storageApi.checkAndFailExpiredMissions();
}

function failActiveMission(missionId) {
  const activeMissions = storageApi.getActiveMissions();
  const missionIdNum = Number(missionId);
  const activeMission = activeMissions.find((m) => Number(m.missionId) === missionIdNum);
  if (!activeMission) return { success: false, message: 'Misión no encontrada' };

  const allMissions = getAllMissionsResolved();
  const mission = allMissions.find((m) => m.id === missionIdNum);
  if (!mission) return { success: false, message: 'Misión no encontrada' };

  const result = storageApi.failActiveMission(missionId);
  gameState = storageApi.loadData();

  return {
    success: true,
    type: 'failed',
    mission,
    remainingLives: result.remainingLives,
    noLives: result.remainingLives === 0,
  };
}

function purchaseReward(rewardId) {
  const allRewards = getAllRewardsResolved();
  const reward = allRewards.find((r) => r.id === rewardId);
  if (!reward) return { success: false, message: 'Recompensa no encontrada' };

  const state = getState();
  if (state.character.level < reward.requiredLevel) {
    return { success: false, message: `Necesitas nivel ${reward.requiredLevel} para desbloquear esto` };
  }

  const result = storageApi.purchaseReward(rewardId, reward.price);
  if (!result.success) return result;

  gameState = storageApi.loadData();
  return { success: true, reward, message: '¡Recompensa comprada con éxito!' };
}

function purchasePotion(potionId) {
  const allRewards = getAllRewardsResolved();
  const potion = allRewards.find((r) => r.id === potionId && r.category === 'potion');
  if (!potion) return { success: false, message: 'Poción no encontrada' };

  const state = getState();
  if (state.character.level < potion.requiredLevel) {
    return { success: false, message: `Necesitas nivel ${potion.requiredLevel} para desbloquear esto` };
  }

  const result = storageApi.purchaseReward(potionId, potion.price);
  if (!result.success) return result;

  storageApi.addPotionToInventory(potionId);
  gameState = storageApi.loadData();
  return { success: true, potion, message: '¡Poción comprada!' };
}

function usePotion(potionId) {
  const allRewards = getAllRewardsResolved();
  const potion = allRewards.find((r) => r.id === potionId && r.category === 'potion');
  if (!potion) return { success: false, message: 'Poción no encontrada' };

  const usageResult = storageApi.usePotion(potionId);
  if (!usageResult.success) return usageResult;

  const state = getState();
  let effectMessage = '';

  if (potion.effect === 'restoreLife') {
    const livesRestored = Math.min(potion.value, state.character.maxLives - state.character.lives);
    storageApi.updateCharacter('lives', Math.min(state.character.lives + potion.value, state.character.maxLives));
    effectMessage = `Recuperaste ${livesRestored} corazón(es) de vida ❤️`;
  } else if (potion.effect === 'restoreEnergy') {
    const energyRestored = Math.min(potion.value, state.character.maxEnergy - state.character.energy);
    storageApi.updateCharacter('energy', Math.min(state.character.energy + potion.value, state.character.maxEnergy));
    effectMessage = `Recuperaste ${energyRestored} punto(s) de energía ⚡`;
  }

  gameState = storageApi.loadData();
  return { success: true, message: effectMessage, potion };
}

function getPotionInventory() {
  return storageApi.getPotionsInventory();
}

function getLevelProgress() {
  const state = getState();
  const requiredXP = calculateXPForLevel(state.character.level);
  const progress = (state.character.xp / requiredXP) * 100;
  return {
    currentXP: state.character.xp,
    requiredXP,
    percentage: Math.min(progress, 100),
    level: state.character.level,
  };
}

function getMissionsByType(type = null) {
  const allMissions = getAllMissionsResolved();
  return type ? allMissions.filter((m) => m.type === type) : allMissions;
}

function getAvailableRewards() {
  const state = getState();
  const allRewards = getAllRewardsResolved();
  return allRewards.map((r) => ({
    ...r,
    unlocked: state.character.level >= r.requiredLevel,
    canPurchase: state.character.gold >= r.price && state.character.level >= r.requiredLevel,
  }));
}

function getTodayMissions() {
  const today = new Date().toDateString();
  const state = getState();
  return state.history.completedMissions.filter((m) => new Date(m.date).toDateString() === today);
}

function calculateStreak() {
  const state = getState();
  const missions = state.history.completedMissions;
  if (missions.length === 0) return 0;

  let streak = 1;
  let currentDay = new Date();
  currentDay.setHours(0, 0, 0, 0);

  for (let i = missions.length - 1; i >= 0; i--) {
    const missionDate = new Date(missions[i].date);
    missionDate.setHours(0, 0, 0, 0);
    const daysDiff = Math.floor((currentDay - missionDate) / (1000 * 60 * 60 * 24));
    if (daysDiff === 1) {
      streak++;
      currentDay = missionDate;
    } else if (daysDiff > 1) {
      break;
    }
  }

  return streak;
}

function resetGame() {
  const confirmation = confirm('¿Estás seguro de que quieres reiniciar todo el progreso? Esta acción no se puede deshacer.');
  if (!confirmation) return { success: false, message: 'Reinicio cancelado' };
  storageApi.resetData();
  gameState = storageApi.loadData();
  return { success: true, message: 'Juego reiniciado' };
}

function resizeAndCompressImage(file, maxWidth, maxHeight, quality) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        let { width, height } = img;

        if (width > height) {
          if (width > maxWidth) {
            height = height * (maxWidth / width);
            width = maxWidth;
          }
        } else if (height > maxHeight) {
          width = width * (maxHeight / height);
          height = maxHeight;
        }

        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0, width, height);

        const compressedBase64 = canvas.toDataURL('image/jpeg', quality);
        const sizeInKB = Math.round((compressedBase64.length * 3) / 4 / 1024);
        if (sizeInKB > 500) {
          reject(new Error('La imagen es demasiado grande incluso después de comprimirla. Intenta con otra foto.'));
          return;
        }

        resolve(compressedBase64);
      };

      img.onerror = () => reject(new Error('Error al cargar la imagen'));
      img.src = e.target.result;
    };

    reader.onerror = () => reject(new Error('Error al leer el archivo'));
    reader.readAsDataURL(file);
  });
}

function uploadAvatar(file) {
  return new Promise(async (resolve, reject) => {
    try {
      if (!file.type.startsWith('image/')) return reject(new Error('El archivo debe ser una imagen'));
      const maxSizeInMB = 10;
      if (file.size > maxSizeInMB * 1024 * 1024) return reject(new Error('La imagen es demasiado grande. Máximo 10MB.'));

      const compressedAvatar = await resizeAndCompressImage(file, 200, 200, 0.8);
      const saved = storageApi.updateCharacter('avatar', compressedAvatar);
      if (!saved) return reject(new Error('No se pudo guardar la imagen. Intenta con una foto más pequeña.'));

      gameState = storageApi.loadData();
      resolve(compressedAvatar);
    } catch (error) {
      reject(error);
    }
  });
}

function getCharacterSummary() {
  const state = getState();
  const progress = getLevelProgress();
  const title = getTitleByLevel(state.character.level);
  const todayStats = storageApi.getTodayStats();
  const streak = calculateStreak();

  return {
    ...state.character,
    title,
    progress,
    todayStats,
    streak,
    totalMissions: state.stats.totalMissions,
    totalSpent: state.stats.totalSpent,
  };
}

function validateCharacterExists() {
  const data = getState();
  if (!data.character.name || data.character.name.trim() === '') {
    window.location.href = 'index.html';
    return false;
  }
  return true;
}

function getEnergyTimerInfo() {
  const state = getState();
  const maxEnergy = state.character.maxEnergy || 6;
  const currentEnergy = state.character.energy || 0;
  if (currentEnergy >= maxEnergy) return { isFull: true };

  const timerInfo = storageApi.getNextEnergyRestoreTime();
  if (!timerInfo) return { isFull: true };
  return {
    isFull: false,
    minutesRemaining: timerInfo.minutesRemaining,
    secondsRemaining: timerInfo.secondsRemaining,
    nextRestoreTime: timerInfo.totalSeconds,
  };
}

function checkAndRestoreEnergy() {
  const data = storageApi.loadData();
  const maxEnergy = data.character.maxEnergy || 6;
  const currentEnergy = data.character.energy || 0;

  if (currentEnergy >= maxEnergy) return { restored: false, newEnergy: currentEnergy };

  if (!data.stats.lastEnergyUpdate) {
    data.stats.lastEnergyUpdate = new Date().toISOString();
    storageApi.saveData(data);
    return { restored: false, newEnergy: currentEnergy };
  }

  const lastUpdate = new Date(data.stats.lastEnergyUpdate);
  const now = new Date();
  const hoursElapsed = (now - lastUpdate) / (1000 * 60 * 60);

  if (hoursElapsed >= 1) {
    const newEnergy = Math.min(currentEnergy + 1, maxEnergy);
    data.character.energy = newEnergy;
    const newUpdateTime = new Date(lastUpdate);
    newUpdateTime.setHours(newUpdateTime.getHours() + Math.floor(hoursElapsed));
    data.stats.lastEnergyUpdate = newUpdateTime.toISOString();
    storageApi.saveData(data);
    gameState = storageApi.loadData();
    return { restored: true, newEnergy };
  }

  return { restored: false, newEnergy: currentEnergy };
}

function getRewardCooldownInfo(rewardId) {
  return storageApi.getRewardCooldownInfo(rewardId);
}

function getCharacterClass() {
  const state = getState();
  const classId = state.character.class;
  if (!classId) return null;
  const classInfo = CLASSES.find((c) => c.id === classId);
  return classInfo || null;
}

export const game = {
  initializeGame,
  getState,
  configureCharacter,
  startMission,
  cancelActiveMission,
  getActiveMissions,
  completeActiveMission,
  failActiveMission,
  checkExpiredMissions,
  purchaseReward,
  purchasePotion,
  usePotion,
  getPotionInventory,
  getLevelProgress,
  getMissionsByType,
  getAvailableRewards,
  getTodayMissions,
  calculateStreak,
  resetGame,
  uploadAvatar,
  getCharacterSummary,
  validateCharacterExists,
  getEnergyTimerInfo,
  checkAndRestoreEnergy,
  getRewardCooldownInfo,
  getCharacterClass,
  // Expuestos por si alguna pantalla los usa directamente
  _REWARDS: REWARDS,
};

