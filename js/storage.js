const STORAGE_KEY = 'heroina_del_hogar_data';

const DEFAULT_DATA = {
    character: {
        name: "",
        avatar: null,
        gender: "",
        class: "",
        level: 1,
        xp: 0,
        gold: 0,
        energy: 6,
        maxEnergy: 6,
        lives: 6,
        maxLives: 6
    },
    inventory: {
        potions: []
    },
    activeMissions: [],
    history: {
        completedMissions: [],
        purchasedRewards: [],
        levelsReached: [1]
    },
    stats: {
        totalMissions: 0,
        totalXP: 0,
        totalGold: 0,
        totalSpent: 0,
        missionsToday: 0,
        lastConnection: new Date().toISOString()
    }
};

function saveData(data) {
    try {
        const jsonString = JSON.stringify(data);
        const sizeInBytes = new Blob([jsonString]).size;
        const maxSize = 4 * 1024 * 1024;
        
        if (sizeInBytes > maxSize) {
            console.error('Data exceeds localStorage limit');
            return false;
        }
        
        localStorage.setItem(STORAGE_KEY, jsonString);
        return true;
    } catch (error) {
        console.error('Error saving data:', error);
        if (error.name === 'QuotaExceededError') {
            alert('Error: No hay espacio suficiente. Intenta eliminar la foto del avatar.');
        }
        return false;
    }
}

function loadData() {
    try {
        const data = localStorage.getItem(STORAGE_KEY);
        if (data) {
            const parsedData = JSON.parse(data);
            
            // Reutilizar objetos Date para optimizar
            const now = new Date();
            const today = now.toDateString();
            const nowISO = now.toISOString();
            
            // Consolidar verificaciones en una sola pasada
            let dataChanged = false;
            const lastConnection = parsedData.stats.lastConnection ? 
                new Date(parsedData.stats.lastConnection).toDateString() : 
                '';
            
            // Verificar si cambió el día
            if (lastConnection !== today) {
                parsedData.stats.missionsToday = 0;
                parsedData.character.energy = parsedData.character.maxEnergy || 6;
                parsedData.stats.lastConnection = nowISO;
                if (!parsedData.stats.lastEnergyUpdate) {
                    parsedData.stats.lastEnergyUpdate = nowISO;
                }
                dataChanged = true;
            }
            
            // Inicializar lastEnergyUpdate si no existe
            if (!parsedData.stats.lastEnergyUpdate) {
                parsedData.stats.lastEnergyUpdate = nowISO;
                dataChanged = true;
            }
            
            // Restaurar energía si es necesario
            const lastEnergyUpdate = new Date(parsedData.stats.lastEnergyUpdate);
            const hoursElapsed = (now - lastEnergyUpdate) / (1000 * 60 * 60);
            const maxEnergy = parsedData.character.maxEnergy || 6;
            
            if (hoursElapsed >= 1 && parsedData.character.energy < maxEnergy) {
                const hoursToRestore = Math.floor(hoursElapsed);
                const energyToAdd = Math.min(hoursToRestore, maxEnergy - parsedData.character.energy);
                
                if (energyToAdd > 0) {
                    parsedData.character.energy = Math.min(
                        parsedData.character.energy + energyToAdd,
                        maxEnergy
                    );
                    
                    const newUpdateTime = new Date(lastEnergyUpdate);
                    newUpdateTime.setHours(newUpdateTime.getHours() + hoursToRestore);
                    parsedData.stats.lastEnergyUpdate = newUpdateTime.toISOString();
                    dataChanged = true;
                }
            }
            
            // Inicializar valores por defecto si faltan
            if (!parsedData.character.maxEnergy) {
                parsedData.character.maxEnergy = 6;
                dataChanged = true;
            }
            
            if (parsedData.character.lives === undefined) {
                parsedData.character.lives = 6;
                parsedData.character.maxLives = 6;
                dataChanged = true;
            }
            
            if (!parsedData.inventory) {
                parsedData.inventory = { potions: [] };
                dataChanged = true;
            }
            
            // Migración: convertir activeMission antiguo a activeMissions array
            if (parsedData.activeMission && !parsedData.activeMissions) {
                parsedData.activeMissions = [parsedData.activeMission];
                delete parsedData.activeMission;
                dataChanged = true;
            } else if (!parsedData.activeMissions) {
                parsedData.activeMissions = [];
                dataChanged = true;
            }
            
            // Guardar cambios de forma síncrona para evitar delays
            if (dataChanged) {
                saveData(parsedData);
            }
            
            if (!validateData(parsedData)) {
                console.warn('Data validation failed, resetting to defaults');
                return { ...DEFAULT_DATA };
            }
            
            return parsedData;
        }
        return { ...DEFAULT_DATA };
    } catch (error) {
        console.error('Error loading data:', error);
        return { ...DEFAULT_DATA };
    }
}

function validateData(data) {
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

function resetData() {
    try {
        localStorage.removeItem(STORAGE_KEY);
        return true;
    } catch (error) {
        console.error('Error resetting data:', error);
        return false;
    }
}

function updateCharacter(field, value) {
    const data = loadData();
    data.character[field] = value;
    return saveData(data);
}

function addXPAndGold(xp, gold) {
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
            data.character.lives = Math.min(
                data.character.lives + 1,
                data.character.maxLives
            );
        }
    }
    
    saveData(data);
    
    return {
        leveledUp,
        previousLevel,
        newLevel: newLevel,
        title: getTitleByLevel(newLevel)
    };
}

function checkLevelUp(currentLevel, currentXP) {
    const requiredXP = calculateXPForLevel(currentLevel);
    
    if (currentXP >= requiredXP) {
        return {
            leveledUp: true,
            newLevel: currentLevel + 1
        };
    }
    
    return {
        leveledUp: false,
        newLevel: currentLevel
    };
}

function registerCompletedMission(missionId, xp, gold) {
    const data = loadData();
    
    const record = {
        missionId,
        date: new Date().toISOString(),
        xpGained: xp,
        goldGained: gold
    };
    
    data.history.completedMissions.push(record);
    data.stats.totalMissions++;
    data.stats.missionsToday++;
    
    saveData(data);
    
    return addXPAndGold(xp, gold);
}

function getRewardCooldownInfo(rewardId) {
    const data = loadData();
    const reward = REWARDS.find(r => r.id === rewardId);
    
    if (!reward || !reward.cooldownHours) {
        return { onCooldown: false };
    }
    
    const purchases = data.history.purchasedRewards.filter(r => r.rewardId === rewardId);
    
    if (purchases.length === 0) {
        return { onCooldown: false };
    }
    
    const lastPurchase = purchases[purchases.length - 1];
    const lastPurchaseDate = new Date(lastPurchase.date);
    const now = new Date();
    const hoursElapsed = (now - lastPurchaseDate) / (1000 * 60 * 60);
    
    if (hoursElapsed >= reward.cooldownHours) {
        return { onCooldown: false };
    }
    
    const hoursRemaining = reward.cooldownHours - hoursElapsed;
    const totalSeconds = Math.floor(hoursRemaining * 3600);
    const hours = Math.floor(hoursRemaining);
    const minutes = Math.floor((hoursRemaining - hours) * 60);
    const seconds = Math.floor(totalSeconds % 60);
    
    return {
        onCooldown: true,
        hoursRemaining: hours,
        minutesRemaining: minutes,
        secondsRemaining: seconds,
        totalSeconds
    };
}

function purchaseReward(rewardId, price) {
    const data = loadData();
    
    if (data.character.gold < price) {
        return { success: false, message: "No tienes suficiente oro" };
    }
    
    const cooldownInfo = getRewardCooldownInfo(rewardId);
    if (cooldownInfo.onCooldown) {
        const hours = cooldownInfo.hoursRemaining;
        const minutes = cooldownInfo.minutesRemaining;
        if (hours > 0) {
            return { success: false, message: `Esta recompensa estará disponible en ${hours}h ${minutes}m` };
        } else {
            return { success: false, message: `Esta recompensa estará disponible en ${minutes}m` };
        }
    }
    
    data.character.gold -= price;
    data.stats.totalSpent += price;
    
    const record = {
        rewardId,
        date: new Date().toISOString(),
        priceSpent: price
    };
    
    data.history.purchasedRewards.push(record);
    
    saveData(data);
    
    return { success: true, message: "¡Recompensa comprada!" };
}

function getTodayStats() {
    const data = loadData();
    const today = new Date().toDateString();
    
    const todayMissions = data.history.completedMissions.filter(m => {
        return new Date(m.date).toDateString() === today;
    });
    
    const todayXP = todayMissions.reduce((sum, m) => sum + m.xpGained, 0);
    const todayGold = todayMissions.reduce((sum, m) => sum + m.goldGained, 0);
    
    return {
        missions: todayMissions.length,
        xp: todayXP,
        gold: todayGold
    };
}

function getPurchasedRewards() {
    const data = loadData();
    return data.history.purchasedRewards;
}

function isRewardPurchased(rewardId) {
    const data = loadData();
    return data.history.purchasedRewards.some(r => r.rewardId === rewardId);
}

function startMission(missionId, name, icon) {
    const data = loadData();
    
    if (!data.activeMissions) {
        data.activeMissions = [];
    }
    
    if (data.activeMissions.length >= 3) {
        return { success: false, message: "Ya tienes 3 misiones activas. Completa o cancela alguna primero." };
    }
    
    if (data.activeMissions.some(m => m.missionId === missionId)) {
        return { success: false, message: "Esta misión ya está en progreso" };
    }
    
    data.character.energy = Math.max(0, data.character.energy - 1);
    
    data.activeMissions.push({
        missionId,
        name,
        icon,
        startDate: new Date().toISOString()
    });
    
    saveData(data);
    return { success: true, message: "Misión iniciada" };
}

function cancelActiveMission(missionId) {
    const data = loadData();
    if (!data.activeMissions) {
        return { success: false, message: "No hay misiones activas" };
    }
    
    const missionIndex = data.activeMissions.findIndex(m => m.missionId === missionId);
    if (missionIndex === -1) {
        return { success: false, message: "Misión no encontrada" };
    }
    
    data.activeMissions.splice(missionIndex, 1);
    saveData(data);
    return { success: true, message: "Misión cancelada" };
}

function getActiveMissions() {
    const data = loadData();
    return data.activeMissions || [];
}

function completeActiveMission(missionId) {
    const data = loadData();
    if (!data.activeMissions) {
        return null;
    }
    
    const missionIndex = data.activeMissions.findIndex(m => m.missionId === missionId);
    if (missionIndex === -1) {
        return null;
    }
    
    const completedMission = data.activeMissions[missionIndex];
    data.activeMissions.splice(missionIndex, 1);
    
    saveData(data);
    return completedMission;
}

function failActiveMission(missionId) {
    const data = loadData();
    if (!data.activeMissions) {
        return null;
    }
    
    const missionIndex = data.activeMissions.findIndex(m => m.missionId === missionId);
    if (missionIndex === -1) {
        return null;
    }
    
    const failedMission = data.activeMissions[missionIndex];
    data.activeMissions.splice(missionIndex, 1);
    data.character.lives = Math.max(0, data.character.lives - 1);
    
    saveData(data);
    return {
        activeMission: failedMission,
        remainingLives: data.character.lives
    };
}

function hasEnoughEnergy() {
    const data = loadData();
    return data.character.energy >= 1;
}

function recoverLife() {
    const data = loadData();
    data.character.lives = Math.min(
        data.character.lives + 1,
        data.character.maxLives
    );
    saveData(data);
    return data.character.lives;
}

function createCharacterWithClass(name, gender, classId, avatar) {
    const data = loadData();
    const selectedClass = CLASSES.find(c => c.id === classId);
    
    if (!selectedClass) {
        return { success: false, message: "Clase no encontrada" };
    }
    
    data.character.name = name;
    data.character.gender = gender;
    data.character.class = classId;
    data.character.avatar = avatar;
    data.character.lives = selectedClass.stats.lives;
    data.character.maxLives = selectedClass.stats.maxLives;
    data.character.energy = selectedClass.stats.energy;
    data.character.maxEnergy = selectedClass.stats.maxEnergy;
    
    saveData(data);
    return { success: true, message: "Personaje creado" };
}

function addPotionToInventory(potionId) {
    const data = loadData();
    const existingPotion = data.inventory.potions.find(p => p.id === potionId);
    
    if (existingPotion) {
        existingPotion.quantity++;
    } else {
        data.inventory.potions.push({ id: potionId, quantity: 1 });
    }
    
    saveData(data);
    return data.inventory.potions;
}

function usePotion(potionId) {
    const data = loadData();
    const potion = data.inventory.potions.find(p => p.id === potionId);
    
    if (!potion || potion.quantity <= 0) {
        return { success: false, message: "No tienes esta poción" };
    }
    
    potion.quantity--;
    
    if (potion.quantity === 0) {
        data.inventory.potions = data.inventory.potions.filter(p => p.id !== potionId);
    }
    
    saveData(data);
    return { success: true, message: "Poción usada" };
}

function getPotionsInventory() {
    const data = loadData();
    return data.inventory.potions || [];
}

function checkAndFailExpiredMissions() {
    const data = loadData();
    if (!data.activeMissions || data.activeMissions.length === 0) {
        return [];
    }
    
    const now = new Date();
    const expiredMissions = [];
    
    data.activeMissions = data.activeMissions.filter(mission => {
        const startDate = new Date(mission.startDate);
        const hoursElapsed = (now - startDate) / (1000 * 60 * 60);
        
        if (hoursElapsed >= 12) {
            expiredMissions.push(mission);
            data.character.lives = Math.max(0, data.character.lives - 1);
            return false;
        }
        return true;
    });
    
    if (expiredMissions.length > 0) {
        saveData(data);
    }
    
    return expiredMissions;
}

function getNextEnergyRestoreTime() {
    const data = loadData();
    const maxEnergy = data.character.maxEnergy || 6;
    const currentEnergy = data.character.energy || 0;
    
    
    if (currentEnergy >= maxEnergy) {
        return null;
    }
    
    if (!data.stats.lastEnergyUpdate) {
        
        const nextUpdate = new Date();
        nextUpdate.setHours(nextUpdate.getHours() + 1);
        const totalSeconds = Math.floor((nextUpdate - new Date()) / 1000);
        const minutesRemaining = Math.floor(totalSeconds / 60);
        const secondsRemaining = totalSeconds % 60;
        
        return {
            minutesRemaining,
            secondsRemaining,
            totalSeconds
        };
    }
    
    const lastUpdate = new Date(data.stats.lastEnergyUpdate);
    const nextUpdate = new Date(lastUpdate);
    nextUpdate.setHours(nextUpdate.getHours() + 1);
    
    const now = new Date();
    const totalSeconds = Math.max(0, Math.floor((nextUpdate - now) / 1000));
    const minutesRemaining = Math.floor(totalSeconds / 60);
    const secondsRemaining = totalSeconds % 60;
    
    return {
        minutesRemaining,
        secondsRemaining,
        totalSeconds
    };
}

function saveFileVersions(versions) {
    try {
        localStorage.setItem('app_file_versions', JSON.stringify(versions));
        return true;
    } catch (error) {
        console.error('Error saving file versions:', error);
        return false;
    }
}

function getFileVersions() {
    try {
        const versions = localStorage.getItem('app_file_versions');
        return versions ? JSON.parse(versions) : {};
    } catch (error) {
        console.error('Error getting file versions:', error);
        return {};
    }
}

function clearFileVersions() {
    try {
        localStorage.removeItem('app_file_versions');
        return true;
    } catch (error) {
        console.error('Error clearing file versions:', error);
        return false;
    }
}

function getCustomMissions() {
    try {
        const missions = localStorage.getItem('custom_missions');
        return missions ? JSON.parse(missions) : [];
    } catch (error) {
        console.error('Error getting custom missions:', error);
        return [];
    }
}

function saveCustomMissions(missions) {
    try {
        localStorage.setItem('custom_missions', JSON.stringify(missions));
        return true;
    } catch (error) {
        console.error('Error saving custom missions:', error);
        return false;
    }
}

function addCustomMission(mission) {
    const missions = getCustomMissions();
    let newId = Date.now();
    while (missions.some(m => m.id === newId)) {
        newId++;
    }
    mission.id = newId;
    missions.push(mission);
    saveCustomMissions(missions);
    return mission;
}

function updateCustomMission(missionId, mission) {
    const missions = getCustomMissions();
    const index = missions.findIndex(m => m.id === missionId);
    if (index === -1) {
        return false;
    }
    mission.id = missionId;
    missions[index] = mission;
    saveCustomMissions(missions);
    return true;
}

function deleteCustomMission(missionId) {
    const missions = getCustomMissions();
    const filtered = missions.filter(m => m.id !== missionId);
    saveCustomMissions(filtered);
    return true;
}

function getCustomRewards() {
    try {
        const rewards = localStorage.getItem('custom_rewards');
        return rewards ? JSON.parse(rewards) : [];
    } catch (error) {
        console.error('Error getting custom rewards:', error);
        return [];
    }
}

function saveCustomRewards(rewards) {
    try {
        localStorage.setItem('custom_rewards', JSON.stringify(rewards));
        return true;
    } catch (error) {
        console.error('Error saving custom rewards:', error);
        return false;
    }
}

function addCustomReward(reward) {
    const rewards = getCustomRewards();
    let newId = Date.now();
    while (rewards.some(r => r.id === newId)) {
        newId++;
    }
    reward.id = newId;
    rewards.push(reward);
    saveCustomRewards(rewards);
    return reward;
}

function updateCustomReward(rewardId, reward) {
    const rewards = getCustomRewards();
    const index = rewards.findIndex(r => r.id === rewardId);
    if (index === -1) {
        return false;
    }
    reward.id = rewardId;
    rewards[index] = reward;
    saveCustomRewards(rewards);
    return true;
}

function deleteCustomReward(rewardId) {
    const rewards = getCustomRewards();
    const filtered = rewards.filter(r => r.id !== rewardId);
    saveCustomRewards(filtered);
    return true;
}

window.storage = {
    saveData,
    loadData,
    resetData,
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
    deleteCustomReward
};
