let gameState = null;

function initializeGame() {
    gameState = window.storage.loadData();
    return gameState;
}

function getState() {
    if (!gameState) {
        initializeGame();
    }
    return gameState;
}

function configureCharacter(name, avatarBase64 = null) {
    window.storage.updateCharacter('name', name);
    if (avatarBase64) {
        window.storage.updateCharacter('avatar', avatarBase64);
    }
    gameState = window.storage.loadData();
    return gameState;
}

function startMission(missionId) {
    const mission = MISSIONS.find(m => m.id === missionId);
    
    if (!mission) {
        return { success: false, message: "Misión no encontrada" };
    }
    
    if (!window.storage.hasEnoughEnergy()) {
        return { 
            success: false, 
            message: "No tienes suficiente energía (necesitas 1 ⚡). Espera a mañana, sube de nivel o usa una poción." 
        };
    }
    
    const result = window.storage.startMission(missionId, mission.name, mission.icon);
    
    if (!result.success) {
        return result;
    }
    
    gameState = window.storage.loadData();
    
    return {
        success: true,
        mission,
        message: "Misión iniciada"
    };
}

function cancelActiveMission() {
    const result = window.storage.cancelActiveMission();
    gameState = window.storage.loadData();
    return result;
}

function getActiveMission() {
    return window.storage.getActiveMission();
}

function completeActiveMission() {
    const activeMission = window.storage.getActiveMission();
    
    if (!activeMission) {
        return { success: false, message: "No hay ninguna misión en progreso" };
    }
    
    const mission = MISSIONS.find(m => m.id === activeMission.missionId);
    
    if (!mission) {
        return { success: false, message: "Misión no encontrada" };
    }
    
    window.storage.completeActiveMission();
    const result = window.storage.registerCompletedMission(mission.id, mission.xp, mission.gold);
    gameState = window.storage.loadData();
    
    return {
        success: true,
        type: 'completed',
        mission,
        xpGained: mission.xp,
        goldGained: mission.gold,
        leveledUp: result.leveledUp,
        newLevel: result.newLevel,
        title: result.title
    };
}

function purchasePotion(potionId) {
    const potion = REWARDS.find(r => r.id === potionId && r.category === 'potion');
    
    if (!potion) {
        return { success: false, message: "Poción no encontrada" };
    }
    
    const state = getState();
    
    if (state.character.level < potion.requiredLevel) {
        return { 
            success: false, 
            message: `Necesitas nivel ${potion.requiredLevel} para desbloquear esto` 
        };
    }
    
    const result = window.storage.purchaseReward(potionId, potion.price);
    
    if (result.success) {
        window.storage.addPotionToInventory(potionId);
        gameState = window.storage.loadData();
        return {
            success: true,
            potion,
            message: "¡Poción comprada!"
        };
    }
    
    return result;
}

function usePotion(potionId) {
    const potion = REWARDS.find(r => r.id === potionId && r.category === 'potion');
    
    if (!potion) {
        return { success: false, message: "Poción no encontrada" };
    }
    
    const usageResult = window.storage.usePotion(potionId);
    
    if (!usageResult.success) {
        return usageResult;
    }
    
    const state = getState();
    let effectMessage = "";
    
    if (potion.effect === "restoreLife") {
        const livesRestored = Math.min(potion.value, state.character.maxLives - state.character.lives);
        window.storage.updateCharacter('lives', Math.min(state.character.lives + potion.value, state.character.maxLives));
        effectMessage = `Recuperaste ${livesRestored} corazón(es) de vida ❤️`;
    } else if (potion.effect === "restoreEnergy") {
        const energyRestored = Math.min(potion.value, state.character.maxEnergy - state.character.energy);
        window.storage.updateCharacter('energy', Math.min(state.character.energy + potion.value, state.character.maxEnergy));
        effectMessage = `Recuperaste ${energyRestored} punto(s) de energía ⚡`;
    }
    
    gameState = window.storage.loadData();
    
    return {
        success: true,
        message: effectMessage,
        potion
    };
}

function getPotionInventory() {
    return window.storage.getPotionsInventory();
}

function failActiveMission() {
    const activeMission = window.storage.getActiveMission();
    
    if (!activeMission) {
        return { success: false, message: "No hay ninguna misión en progreso" };
    }
    
    const mission = MISSIONS.find(m => m.id === activeMission.missionId);
    
    if (!mission) {
        return { success: false, message: "Misión no encontrada" };
    }
    
    const result = window.storage.failActiveMission();
    gameState = window.storage.loadData();
    
    return {
        success: true,
        type: 'failed',
        mission,
        remainingLives: result.remainingLives,
        noLives: result.remainingLives === 0
    };
}

function purchaseReward(rewardId) {
    const reward = REWARDS.find(r => r.id === rewardId);
    
    if (!reward) {
        return { success: false, message: "Recompensa no encontrada" };
    }
    
    const state = getState();
    
    if (state.character.level < reward.requiredLevel) {
        return { 
            success: false, 
            message: `Necesitas nivel ${reward.requiredLevel} para desbloquear esto` 
        };
    }
    
    const result = window.storage.purchaseReward(rewardId, reward.price);
    
    if (result.success) {
        gameState = window.storage.loadData();
        return {
            success: true,
            reward,
            message: "¡Recompensa comprada con éxito!"
        };
    }
    
    return result;
}

function getLevelProgress() {
    const state = getState();
    const requiredXP = calculateXPForLevel(state.character.level);
    const progress = (state.character.xp / requiredXP) * 100;
    
    return {
        currentXP: state.character.xp,
        requiredXP,
        percentage: Math.min(progress, 100),
        level: state.character.level
    };
}

function getMissionsByType(type = null) {
    if (type) {
        return MISSIONS.filter(m => m.type === type);
    }
    return MISSIONS;
}

function getAvailableRewards() {
    const state = getState();
    return REWARDS.map(r => ({
        ...r,
        unlocked: state.character.level >= r.requiredLevel,
        canPurchase: state.character.gold >= r.price && state.character.level >= r.requiredLevel
    }));
}

function getTodayMissions() {
    const today = new Date().toDateString();
    const state = getState();
    
    return state.history.completedMissions.filter(m => {
        return new Date(m.date).toDateString() === today;
    });
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
    
    if (confirmation) {
        window.storage.resetData();
        gameState = window.storage.loadData();
        return { success: true, message: "Juego reiniciado" };
    }
    
    return { success: false, message: "Reinicio cancelado" };
}

function resizeAndCompressImage(file, maxWidth, maxHeight, quality) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        
        reader.onload = (e) => {
            const img = new Image();
            
            img.onload = () => {
                const canvas = document.createElement('canvas');
                let width = img.width;
                let height = img.height;
                
                if (width > height) {
                    if (width > maxWidth) {
                        height = height * (maxWidth / width);
                        width = maxWidth;
                    }
                } else {
                    if (height > maxHeight) {
                        width = width * (maxHeight / height);
                        height = maxHeight;
                    }
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
            
            img.onerror = () => {
                reject(new Error('Error al cargar la imagen'));
            };
            
            img.src = e.target.result;
        };
        
        reader.onerror = () => {
            reject(new Error('Error al leer el archivo'));
        };
        
        reader.readAsDataURL(file);
    });
}

function uploadAvatar(file) {
    return new Promise(async (resolve, reject) => {
        try {
            if (!file.type.startsWith('image/')) {
                reject(new Error('El archivo debe ser una imagen'));
                return;
            }
            
            const maxSizeInMB = 10;
            if (file.size > maxSizeInMB * 1024 * 1024) {
                reject(new Error('La imagen es demasiado grande. Máximo 10MB.'));
                return;
            }
            
            const compressedAvatar = await resizeAndCompressImage(file, 200, 200, 0.8);
            
            const saved = window.storage.updateCharacter('avatar', compressedAvatar);
            
            if (!saved) {
                reject(new Error('No se pudo guardar la imagen. Intenta con una foto más pequeña.'));
                return;
            }
            
            gameState = window.storage.loadData();
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
    const todayStats = window.storage.getTodayStats();
    const streak = calculateStreak();
    
    return {
        ...state.character,
        title,
        progress,
        todayStats,
        streak,
        totalMissions: state.stats.totalMissions,
        totalSpent: state.stats.totalSpent
    };
}

window.game = {
    initializeGame,
    getState,
    configureCharacter,
    startMission,
    cancelActiveMission,
    getActiveMission,
    completeActiveMission,
    failActiveMission,
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
    getCharacterSummary
};

document.addEventListener('DOMContentLoaded', () => {
    initializeGame();
});
