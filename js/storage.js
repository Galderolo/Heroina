const STORAGE_KEY = 'heroina_del_hogar_data';

const DEFAULT_DATA = {
    character: {
        name: "Heroína",
        avatar: null,
        level: 1,
        xp: 0,
        gold: 0,
        energy: 6,
        maxEnergy: 6,
        lives: 6,
        maxLives: 6
    },
    activeMission: null,
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
            parsedData.stats.lastConnection = new Date().toISOString();
            
            const today = new Date().toDateString();
            const lastConnection = new Date(parsedData.stats.lastConnection).toDateString();
            
            if (lastConnection !== today) {
                parsedData.stats.missionsToday = 0;
                parsedData.character.energy = parsedData.character.maxEnergy || 6;
            }
            
            if (!parsedData.character.maxEnergy) {
                parsedData.character.maxEnergy = 6;
            }
            
            if (parsedData.character.lives === undefined) {
                parsedData.character.lives = 6;
                parsedData.character.maxLives = 6;
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
    if (!data || typeof data !== 'object') return false;
    if (!data.character || typeof data.character !== 'object') return false;
    if (!data.history || typeof data.history !== 'object') return false;
    if (!data.stats || typeof data.stats !== 'object') return false;
    if (typeof data.character.level !== 'number') return false;
    if (typeof data.character.xp !== 'number') return false;
    if (typeof data.character.gold !== 'number') return false;
    return true;
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
        
        data.character.energy = Math.min(
            data.character.energy + 2, 
            data.character.maxEnergy
        );
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
    
    if (data.activeMission) {
        return { success: false, message: "Ya hay una misión en progreso" };
    }
    
    data.activeMission = {
        missionId,
        name,
        icon,
        startDate: new Date().toISOString()
    };
    
    saveData(data);
    return { success: true, message: "Misión iniciada" };
}

function cancelActiveMission() {
    const data = loadData();
    data.activeMission = null;
    saveData(data);
    return { success: true, message: "Misión cancelada" };
}

function getActiveMission() {
    const data = loadData();
    return data.activeMission;
}

function completeActiveMission() {
    const data = loadData();
    const activeMission = data.activeMission;
    
    data.character.energy = Math.max(0, data.character.energy - 2);
    
    data.activeMission = null;
    saveData(data);
    return activeMission;
}

function failActiveMission() {
    const data = loadData();
    const activeMission = data.activeMission;
    
    data.character.lives = Math.max(0, data.character.lives - 1);
    data.character.energy = Math.max(0, data.character.energy - 2);
    
    data.activeMission = null;
    saveData(data);
    return {
        activeMission,
        remainingLives: data.character.lives
    };
}

function hasEnoughEnergy() {
    const data = loadData();
    return data.character.energy >= 2;
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
    getActiveMission,
    completeActiveMission,
    failActiveMission,
    hasEnoughEnergy,
    recoverLife
};
