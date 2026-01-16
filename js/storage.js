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
            
            const today = new Date().toDateString();
            const lastConnection = parsedData.stats.lastConnection ? 
                new Date(parsedData.stats.lastConnection).toDateString() : 
                '';
            
            let dataChanged = false;
            if (lastConnection !== today) {
                parsedData.stats.missionsToday = 0;
                parsedData.character.energy = parsedData.character.maxEnergy || 6;
                parsedData.stats.lastConnection = new Date().toISOString();
                dataChanged = true;
            }
            
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
            
            if (dataChanged) {
                setTimeout(() => saveData(parsedData), 100);
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

function purchaseReward(rewardId, price) {
    const data = loadData();
    
    if (data.character.gold < price) {
        return { success: false, message: "No tienes suficiente oro" };
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
    createCharacterWithClass
};
