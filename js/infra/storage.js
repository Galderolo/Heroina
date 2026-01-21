// Persistencia e infra (localStorage) (ES Module)

import { REWARDS, calculateXPForLevel, getTitleByLevel, CLASSES } from '../core/data.js';

export const STORAGE_KEY = 'heroina_del_hogar_data';

// --- Perfiles (globales) ---
const PROFILES_INDEX_KEY = 'heroina_profiles_index';
const ACTIVE_PROFILE_ID_KEY = 'heroina_active_profile_id';
const PROFILE_KEY_PREFIX = 'heroina_profile_';

function safeJsonParse(raw, fallback) {
  try {
    return raw ? JSON.parse(raw) : fallback;
  } catch {
    return fallback;
  }
}

function getProfileDataKey(profileId) {
  return `${PROFILE_KEY_PREFIX}${profileId}`;
}

function loadProfilesIndex() {
  const list = safeJsonParse(localStorage.getItem(PROFILES_INDEX_KEY), []);
  return Array.isArray(list) ? list : [];
}

function saveProfilesIndex(list) {
  try {
    localStorage.setItem(PROFILES_INDEX_KEY, JSON.stringify(list));
    return true;
  } catch (error) {
    console.error('Error saving profiles index:', error);
    return false;
  }
}

function getActiveProfileIdInternal() {
  try {
    const raw = localStorage.getItem(ACTIVE_PROFILE_ID_KEY);
    return raw && raw.trim() ? raw : null;
  } catch {
    return null;
  }
}

function setActiveProfileIdInternal(profileId) {
  try {
    if (!profileId) {
      localStorage.removeItem(ACTIVE_PROFILE_ID_KEY);
      return true;
    }
    localStorage.setItem(ACTIVE_PROFILE_ID_KEY, String(profileId));
    return true;
  } catch (error) {
    console.error('Error setting active profile:', error);
    return false;
  }
}

function ensureProfilesMigrated() {
  const nowISO = new Date().toISOString();
  let profiles = loadProfilesIndex();
  let activeId = getActiveProfileIdInternal();

  // Migración desde el storage legacy (1 único perfil)
  if (profiles.length === 0) {
    const legacy = localStorage.getItem(STORAGE_KEY);
    if (legacy) {
      const legacyParsed = safeJsonParse(legacy, null);

      // Si el legacy está “vacío” (sin personaje/progreso), NO lo migramos para que
      // `perfiles.html` empiece realmente sin perfiles y el usuario elija crearlo.
      try {
        const name = (legacyParsed?.character?.name || '').trim();
        const hasActive = Array.isArray(legacyParsed?.activeMissions) && legacyParsed.activeMissions.length > 0;
        const hasCompleted = Array.isArray(legacyParsed?.history?.completedMissions) && legacyParsed.history.completedMissions.length > 0;
        const hasPurchases = Array.isArray(legacyParsed?.history?.purchasedRewards) && legacyParsed.history.purchasedRewards.length > 0;
        const totalMissions = Number(legacyParsed?.stats?.totalMissions || 0);
        const totalGold = Number(legacyParsed?.stats?.totalGold || 0);
        const totalXP = Number(legacyParsed?.stats?.totalXP || 0);
        const hasProgress = !!name || hasActive || hasCompleted || hasPurchases || totalMissions > 0 || totalGold > 0 || totalXP > 0;

        if (!hasProgress) {
          localStorage.removeItem(STORAGE_KEY);
          return { profiles, activeId };
        }
      } catch (_) {
        // si no podemos determinarlo, migramos por seguridad
      }

      let id = 'p1';
      if (localStorage.getItem(getProfileDataKey(id))) id = `p${Date.now()}`;

      try {
        localStorage.setItem(getProfileDataKey(id), legacy);
        localStorage.removeItem(STORAGE_KEY);
      } catch (e) {
        console.error('Error migrating legacy profile:', e);
      }

      profiles = [
        {
          id,
          name: legacyParsed?.character?.name || '',
          avatar: legacyParsed?.character?.avatar || null,
          createdAt: nowISO,
          lastUsedAt: nowISO,
        },
      ];
      saveProfilesIndex(profiles);
      setActiveProfileIdInternal(id);
      activeId = id;
    }
  }

  // Normalizar activeId
  if (activeId && !profiles.some((p) => p?.id === activeId)) {
    activeId = null;
    setActiveProfileIdInternal(null);
  }

  // Autoselección si solo hay 1 perfil
  if (!activeId && profiles.length === 1) {
    activeId = profiles[0].id;
    setActiveProfileIdInternal(activeId);
  }

  return { profiles, activeId };
}

function clone(obj) {
  if (typeof structuredClone === 'function') return structuredClone(obj);
  return JSON.parse(JSON.stringify(obj));
}

export const DEFAULT_DATA = {
  character: {
    name: '',
    avatar: null,
    gender: '',
    class: '',
    level: 1,
    xp: 0,
    gold: 0,
    energy: 6,
    maxEnergy: 6,
    lives: 6,
    maxLives: 6,
  },
  inventory: { potions: [] },
  activeMissions: [],
  history: {
    completedMissions: [],
    purchasedRewards: [],
    levelsReached: [1],
  },
  stats: {
    totalMissions: 0,
    totalXP: 0,
    totalGold: 0,
    totalSpent: 0,
    missionsToday: 0,
    lastConnection: null,
    lastEnergyUpdate: null,
  },
};

export function saveData(data) {
  try {
    const jsonString = JSON.stringify(data);
    const sizeInBytes = new Blob([jsonString]).size;
    const maxSize = 4 * 1024 * 1024;

    if (sizeInBytes > maxSize) {
      console.error('Data exceeds localStorage limit');
      return false;
    }

    const { profiles, activeId } = ensureProfilesMigrated();
    let profileId = activeId;

    // Caso extremo: nadie creó perfil todavía -> crear uno implícito para no romper flujo
    if (!profileId) {
      profileId = `p${Date.now()}`;
      const nowISO = new Date().toISOString();
      const newProfiles = [
        ...profiles,
        { id: profileId, name: data?.character?.name || '', avatar: data?.character?.avatar || null, createdAt: nowISO, lastUsedAt: nowISO },
      ];
      saveProfilesIndex(newProfiles);
      setActiveProfileIdInternal(profileId);
    }

    localStorage.setItem(getProfileDataKey(profileId), jsonString);

    // Sincronizar metadata en el índice (nombre/avatar del personaje)
    try {
      const list = loadProfilesIndex();
      const idx = list.findIndex((p) => p?.id === profileId);
      const nowISO = new Date().toISOString();
      const name = data?.character?.name || '';
      const avatar = data?.character?.avatar || null;
      if (idx >= 0) {
        list[idx] = { ...list[idx], name, avatar, lastUsedAt: nowISO };
      } else {
        list.push({ id: profileId, name, avatar, createdAt: nowISO, lastUsedAt: nowISO });
      }
      saveProfilesIndex(list);
    } catch (_) {
      // ignore
    }
    return true;
  } catch (error) {
    console.error('Error saving data:', error);
    if (error?.name === 'QuotaExceededError') {
      alert('Error: No hay espacio suficiente. Intenta eliminar la foto del avatar.');
    }
    return false;
  }
}

export function validateData(data) {
  try {
    if (!data || typeof data !== 'object') return false;
    if (!data.character || typeof data.character !== 'object') return false;
    if (!data.history || typeof data.history !== 'object') return false;
    if (!data.stats || typeof data.stats !== 'object') return false;
    if (typeof data.character.level !== 'number') return false;
    if (typeof data.character.xp !== 'number') return false;
    if (typeof data.character.gold !== 'number') return false;
    return true;
  } catch (error) {
    console.error('Validation error:', error);
    return false;
  }
}

export function loadData() {
  try {
    const { activeId } = ensureProfilesMigrated();
    if (!activeId) {
      // No hay perfiles aún: devolvemos estado “vacío” sin persistir
      const fresh = clone(DEFAULT_DATA);
      fresh.stats.lastConnection = new Date().toISOString();
      fresh.stats.lastEnergyUpdate = null;
      return fresh;
    }

    const dataStr = localStorage.getItem(getProfileDataKey(activeId));
    if (!dataStr) {
      const fresh = clone(DEFAULT_DATA);
      fresh.stats.lastConnection = new Date().toISOString();
      // Timer de energía inactivo al empezar con energía llena
      fresh.stats.lastEnergyUpdate = null;
      saveData(fresh);
      return fresh;
    }

    const parsedData = JSON.parse(dataStr);

    const now = new Date();
    const today = now.toDateString();
    const nowISO = now.toISOString();
    let dataChanged = false;

    const lastConnectionDay = parsedData?.stats?.lastConnection
      ? new Date(parsedData.stats.lastConnection).toDateString()
      : '';

    if (!parsedData.stats) parsedData.stats = clone(DEFAULT_DATA.stats);
    if (!parsedData.character) parsedData.character = clone(DEFAULT_DATA.character);
    if (!parsedData.history) parsedData.history = clone(DEFAULT_DATA.history);

    // Migraciones y defaults críticos (antes de usar maxEnergy)
    if (
      typeof parsedData.character.maxEnergy !== 'number' ||
      !Number.isFinite(parsedData.character.maxEnergy) ||
      parsedData.character.maxEnergy <= 0
    ) {
      parsedData.character.maxEnergy = 6;
      dataChanged = true;
    }

    // Día nuevo: reset de misiones de hoy y energía.
    if (lastConnectionDay !== today) {
      parsedData.stats.missionsToday = 0;
      parsedData.character.energy = parsedData.character.maxEnergy;
      parsedData.stats.lastConnection = nowISO;
      // Al estar a energía full, el contador no debe estar activo
      parsedData.stats.lastEnergyUpdate = null;
      dataChanged = true;
    }

    // Normalización del timer de energía:
    // - Si estamos a energía full, el contador se considera inactivo (null)
    // - Si falta energía y no hay timer, se inicia (nowISO)
    const maxEnergyNow = parsedData.character.maxEnergy;
    const currentEnergyNow = parsedData.character.energy || 0;
    if (currentEnergyNow >= maxEnergyNow) {
      if (parsedData.stats.lastEnergyUpdate) {
        parsedData.stats.lastEnergyUpdate = null;
        dataChanged = true;
      }
    } else {
      if (!parsedData.stats.lastEnergyUpdate) {
        parsedData.stats.lastEnergyUpdate = nowISO;
        dataChanged = true;
      }
    }

    // Migraciones y defaults
    if (!parsedData.inventory) {
      parsedData.inventory = { potions: [] };
      dataChanged = true;
    }

    if (parsedData.activeMission && !parsedData.activeMissions) {
      parsedData.activeMissions = [parsedData.activeMission];
      delete parsedData.activeMission;
      dataChanged = true;
    } else if (!parsedData.activeMissions) {
      parsedData.activeMissions = [];
      dataChanged = true;
    }

    if (parsedData.character.lives === undefined) {
      parsedData.character.lives = 6;
      parsedData.character.maxLives = 6;
      dataChanged = true;
    }

    // Restaurar energía en base a lastEnergyUpdate (1 energía / hora mientras falte)
    const maxEnergy = parsedData.character.maxEnergy || 6;
    const currentEnergy = parsedData.character.energy || 0;
    const lastEnergyUpdateISO = parsedData.stats.lastEnergyUpdate;

    if (currentEnergy < maxEnergy && lastEnergyUpdateISO) {
      const lastEnergyUpdate = new Date(lastEnergyUpdateISO);
      const lastTs = lastEnergyUpdate.getTime();

      // Si el timestamp es inválido, reiniciamos el timer desde ahora
      if (Number.isNaN(lastTs)) {
        parsedData.stats.lastEnergyUpdate = nowISO;
        dataChanged = true;
      } else {
        const hoursElapsed = (now.getTime() - lastTs) / (1000 * 60 * 60);
        if (hoursElapsed >= 1) {
          const hoursToRestore = Math.floor(hoursElapsed);
          const missing = maxEnergy - currentEnergy;
          const energyToAdd = Math.min(hoursToRestore, missing);

          if (energyToAdd > 0) {
            const newEnergy = Math.min(currentEnergy + energyToAdd, maxEnergy);
            parsedData.character.energy = newEnergy;

            // Avanzar el timer SOLO tantas horas como energía se haya recuperado
            const newUpdateTime = new Date(lastTs + energyToAdd * 60 * 60 * 1000);

            // Si llegamos a full, el contador se apaga
            parsedData.stats.lastEnergyUpdate = newEnergy >= maxEnergy ? null : newUpdateTime.toISOString();
            dataChanged = true;
          }
        }
      }
    }

    if (dataChanged) saveData(parsedData);

    if (!validateData(parsedData)) {
      console.warn('Data validation failed, resetting to defaults');
      const fresh = clone(DEFAULT_DATA);
      fresh.stats.lastConnection = nowISO;
      // Reset: empezamos con energía full => contador inactivo
      fresh.stats.lastEnergyUpdate = null;
      saveData(fresh);
      return fresh;
    }

    return parsedData;
  } catch (error) {
    console.error('Error loading data:', error);
    const fresh = clone(DEFAULT_DATA);
    fresh.stats.lastConnection = new Date().toISOString();
    fresh.stats.lastEnergyUpdate = null;
    return fresh;
  }
}

export function resetData() {
  try {
    // Reset del perfil activo (no borra el perfil)
    const { activeId } = ensureProfilesMigrated();
    if (!activeId) return false;

    const fresh = clone(DEFAULT_DATA);
    fresh.stats.lastConnection = new Date().toISOString();
    fresh.stats.lastEnergyUpdate = null;
    saveData(fresh);
    return true;
  } catch (error) {
    console.error('Error resetting data:', error);
    return false;
  }
}

// --- API Perfiles (exportable) ---
export function listProfiles() {
  ensureProfilesMigrated();
  return loadProfilesIndex();
}

export function getActiveProfileId() {
  ensureProfilesMigrated();
  return getActiveProfileIdInternal();
}

export function setActiveProfile(profileId) {
  const { profiles } = ensureProfilesMigrated();
  if (!profileId || !profiles.some((p) => p?.id === profileId)) return false;
  return setActiveProfileIdInternal(profileId);
}

export function createProfile() {
  ensureProfilesMigrated();
  const id = `p${Date.now()}`;
  const nowISO = new Date().toISOString();

  const list = loadProfilesIndex();
  list.push({ id, name: '', avatar: null, createdAt: nowISO, lastUsedAt: nowISO });
  saveProfilesIndex(list);
  setActiveProfileIdInternal(id);

  const fresh = clone(DEFAULT_DATA);
  fresh.stats.lastConnection = nowISO;
  fresh.stats.lastEnergyUpdate = null;
  // Persistir el estado inicial del perfil
  try {
    localStorage.setItem(getProfileDataKey(id), JSON.stringify(fresh));
  } catch (e) {
    console.error('Error creating profile data:', e);
  }

  return { id };
}

export function deleteProfile(profileId) {
  ensureProfilesMigrated();
  if (!profileId) return false;

  const list = loadProfilesIndex().filter((p) => p?.id !== profileId);
  saveProfilesIndex(list);

  try {
    localStorage.removeItem(getProfileDataKey(profileId));
  } catch (e) {
    console.error('Error deleting profile data:', e);
  }

  const activeId = getActiveProfileIdInternal();
  if (activeId === profileId) {
    const next = list.length === 1 ? list[0].id : null;
    setActiveProfileIdInternal(next);
  }

  return true;
}

export function getProfileSummary(profileId) {
  ensureProfilesMigrated();
  if (!profileId) return null;

  try {
    const raw = localStorage.getItem(getProfileDataKey(profileId));
    if (!raw) return null;
    const data = safeJsonParse(raw, null);
    if (!data || !data.character) return null;

    const level = Number(data.character.level || 1);
    const classId = data.character.class || '';
    const classInfo = CLASSES.find((c) => c.id === classId);
    const className = classInfo ? classInfo.name : null;
    const title = getTitleByLevel(level);
    const displayTitle = className ? `${className} ${title}` : title;

    return {
      level,
      classId,
      title,
      className,
      displayTitle,
    };
  } catch (error) {
    console.error('Error getting profile summary:', error);
    return null;
  }
}

export function updateCharacter(field, value) {
  const data = loadData();
  data.character[field] = value;
  // Reglas del temporizador de energía:
  // - Si la energía queda full, el timer se apaga (null)
  // - Si falta energía y no hay timer, se inicia (now)
  if (field === 'energy') {
    const maxEnergy = data.character.maxEnergy || 6;
    const energy = data.character.energy || 0;
    if (energy >= maxEnergy) data.stats.lastEnergyUpdate = null;
    else if (!data.stats.lastEnergyUpdate) data.stats.lastEnergyUpdate = new Date().toISOString();
  }
  return saveData(data);
}

export function checkLevelUp(currentLevel, currentXP) {
  const requiredXP = calculateXPForLevel(currentLevel);
  if (currentXP >= requiredXP) return { leveledUp: true, newLevel: currentLevel + 1 };
  return { leveledUp: false, newLevel: currentLevel };
}

export function addXPAndGold(xp, gold) {
  const data = loadData();
  data.character.xp += xp;
  data.character.gold += gold;
  data.stats.totalXP += xp;
  data.stats.totalGold += gold;

  const previousLevel = data.character.level;
  const { newLevel, leveledUp } = checkLevelUp(data.character.level, data.character.xp);

  if (leveledUp) {
    data.character.level = newLevel;
    data.character.xp = 0;
    data.history.levelsReached.push(newLevel);

    if (data.character.lives < data.character.maxLives) {
      data.character.lives = Math.min(data.character.lives + 1, data.character.maxLives);
    }
  }

  saveData(data);

  return {
    leveledUp,
    previousLevel,
    newLevel,
    title: getTitleByLevel(newLevel),
  };
}

export function registerCompletedMission(missionId, xp, gold) {
  const data = loadData();
  const record = { missionId, date: new Date().toISOString(), xpGained: xp, goldGained: gold };
  data.history.completedMissions.push(record);
  data.stats.totalMissions++;
  data.stats.missionsToday++;
  saveData(data);
  return addXPAndGold(xp, gold);
}

export function getRewardCooldownInfo(rewardId) {
  const data = loadData();
  const reward = REWARDS.find((r) => r.id === rewardId);
  if (!reward || !reward.cooldownHours) return { onCooldown: false };

  const purchases = data.history.purchasedRewards.filter((r) => r.rewardId === rewardId);
  if (purchases.length === 0) return { onCooldown: false };

  const lastPurchase = purchases[purchases.length - 1];
  const lastPurchaseDate = new Date(lastPurchase.date);
  const now = new Date();
  const hoursElapsed = (now - lastPurchaseDate) / (1000 * 60 * 60);

  if (hoursElapsed >= reward.cooldownHours) return { onCooldown: false };

  const hoursRemaining = reward.cooldownHours - hoursElapsed;
  const totalSeconds = Math.floor(hoursRemaining * 3600);
  const hours = Math.floor(hoursRemaining);
  const minutes = Math.floor((hoursRemaining - hours) * 60);
  const seconds = Math.floor(totalSeconds % 60);

  return { onCooldown: true, hoursRemaining: hours, minutesRemaining: minutes, secondsRemaining: seconds, totalSeconds };
}

export function purchaseReward(rewardId, price) {
  const data = loadData();
  if (data.character.gold < price) return { success: false, message: 'No tienes suficiente oro' };

  const cooldownInfo = getRewardCooldownInfo(rewardId);
  if (cooldownInfo.onCooldown) {
    const hours = cooldownInfo.hoursRemaining;
    const minutes = cooldownInfo.minutesRemaining;
    if (hours > 0) return { success: false, message: `Esta recompensa estará disponible en ${hours}h ${minutes}m` };
    return { success: false, message: `Esta recompensa estará disponible en ${minutes}m` };
  }

  data.character.gold -= price;
  data.stats.totalSpent += price;

  const record = { rewardId, date: new Date().toISOString(), priceSpent: price };
  data.history.purchasedRewards.push(record);
  saveData(data);
  return { success: true, message: '¡Recompensa comprada!' };
}

export function getTodayStats() {
  const data = loadData();
  const today = new Date().toDateString();
  const todayMissions = data.history.completedMissions.filter((m) => new Date(m.date).toDateString() === today);
  const todayXP = todayMissions.reduce((sum, m) => sum + m.xpGained, 0);
  const todayGold = todayMissions.reduce((sum, m) => sum + m.goldGained, 0);
  return { missions: todayMissions.length, xp: todayXP, gold: todayGold };
}

export function getPurchasedRewards() {
  return loadData().history.purchasedRewards;
}

export function isRewardPurchased(rewardId) {
  return loadData().history.purchasedRewards.some((r) => r.rewardId === rewardId);
}

export function hasEnoughEnergy() {
  return loadData().character.energy >= 1;
}

export function startMission(missionId, name, icon) {
  const data = loadData();
  if (!data.activeMissions) data.activeMissions = [];
  if (data.activeMissions.length >= 3) return { success: false, message: 'Ya tienes 3 misiones activas. Completa o cancela alguna primero.' };
  if (data.activeMissions.some((m) => m.missionId === missionId)) return { success: false, message: 'Esta misión ya está en progreso' };

  const maxEnergy = data.character.maxEnergy || 6;
  const hadTimer = !!data.stats.lastEnergyUpdate;
  data.character.energy = Math.max(0, data.character.energy - 1);

  // Regla: al gastar energía, si el contador no estaba activo y ahora falta energía, se inicia.
  if (!hadTimer && (data.character.energy || 0) < maxEnergy) {
    data.stats.lastEnergyUpdate = new Date().toISOString();
  }
  data.activeMissions.push({ missionId, name, icon, startDate: new Date().toISOString() });
  saveData(data);
  return { success: true, message: 'Misión iniciada' };
}

export function cancelActiveMission(missionId) {
  const data = loadData();
  if (!data.activeMissions) return { success: false, message: 'No hay misiones activas' };
  const idx = data.activeMissions.findIndex((m) => m.missionId === missionId);
  if (idx === -1) return { success: false, message: 'Misión no encontrada' };
  data.activeMissions.splice(idx, 1);
  saveData(data);
  return { success: true, message: 'Misión cancelada' };
}

export function getActiveMissions() {
  return loadData().activeMissions || [];
}

export function completeActiveMission(missionId) {
  const data = loadData();
  if (!data.activeMissions) return null;
  const idx = data.activeMissions.findIndex((m) => m.missionId === missionId);
  if (idx === -1) return null;
  const completed = data.activeMissions[idx];
  data.activeMissions.splice(idx, 1);
  saveData(data);
  return completed;
}

export function failActiveMission(missionId) {
  const data = loadData();
  if (!data.activeMissions) return null;
  const idx = data.activeMissions.findIndex((m) => m.missionId === missionId);
  if (idx === -1) return null;
  const failed = data.activeMissions[idx];
  data.activeMissions.splice(idx, 1);
  data.character.lives = Math.max(0, data.character.lives - 1);
  saveData(data);
  return { activeMission: failed, remainingLives: data.character.lives };
}

export function recoverLife() {
  const data = loadData();
  data.character.lives = Math.min(data.character.lives + 1, data.character.maxLives);
  saveData(data);
  return data.character.lives;
}

export function checkAndFailExpiredMissions() {
  const data = loadData();
  if (!data.activeMissions || data.activeMissions.length === 0) return [];
  const now = new Date();
  const expired = [];

  data.activeMissions = data.activeMissions.filter((mission) => {
    const startDate = new Date(mission.startDate);
    const hoursElapsed = (now - startDate) / (1000 * 60 * 60);
    if (hoursElapsed >= 12) {
      expired.push(mission);
      data.character.lives = Math.max(0, data.character.lives - 1);
      return false;
    }
    return true;
  });

  if (expired.length > 0) saveData(data);
  return expired;
}

export function getNextEnergyRestoreTime() {
  const data = loadData();
  const maxEnergy = data.character.maxEnergy || 6;
  const currentEnergy = data.character.energy || 0;
  if (currentEnergy >= maxEnergy) return null;

  if (!data.stats.lastEnergyUpdate) {
    const nextUpdate = new Date();
    nextUpdate.setHours(nextUpdate.getHours() + 1);
    const totalSeconds = Math.floor((nextUpdate - new Date()) / 1000);
    return { minutesRemaining: Math.floor(totalSeconds / 60), secondsRemaining: totalSeconds % 60, totalSeconds };
  }

  const lastUpdate = new Date(data.stats.lastEnergyUpdate);
  const nextUpdate = new Date(lastUpdate);
  nextUpdate.setHours(nextUpdate.getHours() + 1);
  const now = new Date();
  const totalSeconds = Math.max(0, Math.floor((nextUpdate - now) / 1000));
  return { minutesRemaining: Math.floor(totalSeconds / 60), secondsRemaining: totalSeconds % 60, totalSeconds };
}

export function addPotionToInventory(potionId) {
  const data = loadData();
  const existing = data.inventory.potions.find((p) => p.id === potionId);
  if (existing) existing.quantity++;
  else data.inventory.potions.push({ id: potionId, quantity: 1 });
  saveData(data);
  return data.inventory.potions;
}

export function usePotion(potionId) {
  const data = loadData();
  const potion = data.inventory.potions.find((p) => p.id === potionId);
  if (!potion || potion.quantity <= 0) return { success: false, message: 'No tienes esta poción' };

  potion.quantity--;
  if (potion.quantity === 0) data.inventory.potions = data.inventory.potions.filter((p) => p.id !== potionId);
  saveData(data);
  return { success: true, message: 'Poción usada' };
}

export function getPotionsInventory() {
  return loadData().inventory.potions || [];
}

export function createCharacterWithClass(name, gender, classId, avatar) {
  const data = loadData();
  const selectedClass = CLASSES.find((c) => c.id === classId);
  if (!selectedClass) return { success: false, message: 'Clase no encontrada' };

  data.character.name = name;
  data.character.gender = gender;
  data.character.class = classId;
  data.character.avatar = avatar;
  data.character.lives = selectedClass.stats.lives;
  data.character.maxLives = selectedClass.stats.maxLives;
  data.character.energy = selectedClass.stats.energy;
  data.character.maxEnergy = selectedClass.stats.maxEnergy;
  // Al crear, si empieza a full el contador queda inactivo
  data.stats.lastEnergyUpdate = data.character.energy >= data.character.maxEnergy ? null : new Date().toISOString();

  saveData(data);
  return { success: true, message: 'Personaje creado' };
}

export function saveFileVersions(versions) {
  try {
    localStorage.setItem('app_file_versions', JSON.stringify(versions));
    return true;
  } catch (error) {
    console.error('Error saving file versions:', error);
    return false;
  }
}

export function getFileVersions() {
  try {
    const versions = localStorage.getItem('app_file_versions');
    return versions ? JSON.parse(versions) : {};
  } catch (error) {
    console.error('Error getting file versions:', error);
    return {};
  }
}

export function clearFileVersions() {
  try {
    localStorage.removeItem('app_file_versions');
    return true;
  } catch (error) {
    console.error('Error clearing file versions:', error);
    return false;
  }
}

export function getCustomMissions() {
  try {
    const missions = localStorage.getItem('custom_missions');
    return missions ? JSON.parse(missions) : [];
  } catch (error) {
    console.error('Error getting custom missions:', error);
    return [];
  }
}

export function saveCustomMissions(missions) {
  try {
    localStorage.setItem('custom_missions', JSON.stringify(missions));
    return true;
  } catch (error) {
    console.error('Error saving custom missions:', error);
    return false;
  }
}

export function addCustomMission(mission) {
  const missions = getCustomMissions();
  let newId = Date.now();
  while (missions.some((m) => m.id === newId)) newId++;
  mission.id = newId;
  missions.push(mission);
  saveCustomMissions(missions);
  return mission;
}

export function updateCustomMission(missionId, mission) {
  const missions = getCustomMissions();
  const idx = missions.findIndex((m) => m.id === missionId);
  if (idx === -1) return false;
  mission.id = missionId;
  missions[idx] = mission;
  saveCustomMissions(missions);
  return true;
}

export function deleteCustomMission(missionId) {
  const missions = getCustomMissions();
  saveCustomMissions(missions.filter((m) => m.id !== missionId));
  return true;
}

export function getCustomRewards() {
  try {
    const rewards = localStorage.getItem('custom_rewards');
    return rewards ? JSON.parse(rewards) : [];
  } catch (error) {
    console.error('Error getting custom rewards:', error);
    return [];
  }
}

export function saveCustomRewards(rewards) {
  try {
    localStorage.setItem('custom_rewards', JSON.stringify(rewards));
    return true;
  } catch (error) {
    console.error('Error saving custom rewards:', error);
    return false;
  }
}

export function addCustomReward(reward) {
  const rewards = getCustomRewards();
  let newId = Date.now();
  while (rewards.some((r) => r.id === newId)) newId++;
  reward.id = newId;
  rewards.push(reward);
  saveCustomRewards(rewards);
  return reward;
}

export function updateCustomReward(rewardId, reward) {
  const rewards = getCustomRewards();
  const idx = rewards.findIndex((r) => r.id === rewardId);
  if (idx === -1) return false;
  reward.id = rewardId;
  rewards[idx] = reward;
  saveCustomRewards(rewards);
  return true;
}

export function deleteCustomReward(rewardId) {
  const rewards = getCustomRewards();
  saveCustomRewards(rewards.filter((r) => r.id !== rewardId));
  return true;
}

export const storage = {
  STORAGE_KEY,
  DEFAULT_DATA,
  saveData,
  loadData,
  resetData,
  // Perfiles
  listProfiles,
  getActiveProfileId,
  setActiveProfile,
  createProfile,
  deleteProfile,
  getProfileSummary,
  updateCharacter,
  addXPAndGold,
  registerCompletedMission,
  purchaseReward,
  getTodayStats,
  getPurchasedRewards,
  isRewardPurchased,
  startMission,
  cancelActiveMission,
  getActiveMissions,
  completeActiveMission,
  failActiveMission,
  hasEnoughEnergy,
  recoverLife,
  addPotionToInventory,
  usePotion,
  getPotionsInventory,
  checkAndFailExpiredMissions,
  createCharacterWithClass,
  getNextEnergyRestoreTime,
  saveFileVersions,
  getFileVersions,
  clearFileVersions,
  getRewardCooldownInfo,
  getCustomMissions,
  saveCustomMissions,
  addCustomMission,
  updateCustomMission,
  deleteCustomMission,
  getCustomRewards,
  saveCustomRewards,
  addCustomReward,
  updateCustomReward,
  deleteCustomReward,
};

