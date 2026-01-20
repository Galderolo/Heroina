// Compat ES Modules: re-export de `js/ui/modals.js`
// Nota: el código fuente real ahora vive en `js/ui/modals.js`.

export * from './ui/modals.js';

let confirmCallback = null;
let cancelCallback = null;

function showAlert(message, title = "Aviso", icon = "ℹ️") {
    const modal = document.getElementById('customAlert');
    const iconEl = document.getElementById('alertIcon');
    const titleEl = document.getElementById('alertTitle');
    const messageEl = document.getElementById('alertMessage');
    
    iconEl.textContent = icon;
    titleEl.textContent = title;
    messageEl.textContent = message;
    
    modal.style.display = 'block';
    
    setTimeout(() => {
        modal.querySelector('.custom-modal-content').style.animation = 'modalSlideIn 0.4s ease';
    }, 10);
}

function closeAlert() {
    const modal = document.getElementById('customAlert');
    modal.style.display = 'none';
}

function showSuccess(message, title = "¡Éxito!") {
    showAlert(message, title, "✅");
}

function showError(message, title = "Error") {
    showAlert(message, title, "❌");
}

function showInfo(message, title = "Información") {
    showAlert(message, title, "ℹ️");
}

function showConfirm(message, title = "Confirmar", onConfirm = null, onCancel = null) {
    const modal = document.getElementById('customConfirm');
    const titleEl = document.getElementById('confirmTitle');
    const messageEl = document.getElementById('confirmMessage');
    const yesBtn = document.getElementById('confirmYes');
    const noBtn = document.getElementById('confirmNo');
    
    titleEl.textContent = title;
    messageEl.textContent = message;
    
    confirmCallback = onConfirm;
    cancelCallback = onCancel;
    
    modal.style.display = 'block';
    
    setTimeout(() => {
        modal.querySelector('.custom-modal-content').style.animation = 'modalSlideIn 0.4s ease';
    }, 10);
}

function closeConfirm(confirmed) {
    const modal = document.getElementById('customConfirm');
    modal.style.display = 'none';
    
    if (confirmed && confirmCallback) {
        confirmCallback();
    } else if (!confirmed && cancelCallback) {
        cancelCallback();
    }
    
    confirmCallback = null;
    cancelCallback = null;
}

document.addEventListener('DOMContentLoaded', () => {
    const confirmYesBtn = document.getElementById('confirmYes');
    const confirmNoBtn = document.getElementById('confirmNo');
    
    if (confirmYesBtn) {
        confirmYesBtn.onclick = () => closeConfirm(true);
    }
    
    if (confirmNoBtn) {
        confirmNoBtn.onclick = () => closeConfirm(false);
    }
});

function showReward(xpGained, goldGained, levelUp = null, missionIcon = null, missionName = null) {
    const modal = document.getElementById('customReward');
    const detailsEl = document.getElementById('rewardDetails');
    const titleEl = document.getElementById('rewardTitle');
    const animationEl = document.querySelector('.reward-animation');
    
    if (missionIcon && animationEl) {
        animationEl.textContent = missionIcon;
        animationEl.style.fontSize = '4rem';
    }
    
    if (missionName && titleEl) {
        titleEl.innerHTML = `¡Misión Completada!<br><small style="font-size: 1.2rem; color: #c0c0c0;">${missionName}</small>`;
    } else if (titleEl) {
        titleEl.textContent = '¡Misión Completada!';
    }
    
    let detailsHTML = `
        <div style="display: flex; justify-content: center; gap: 2rem; font-size: 1.5rem;">
            <div>
                <i class="bi bi-star-fill" style="color: #00d4ff;"></i> <span style="color: #00d4ff;">+${xpGained} XP</span>
            </div>
            <div>
                <i class="bi bi-coin" style="color: #ffd700;"></i> <span style="color: #ffd700;">+${goldGained} Oro</span>
            </div>
        </div>
    `;
    
    if (levelUp) {
        detailsHTML += `
            <div style="margin-top: 1.5rem; padding: 1rem; background: rgba(255, 215, 0, 0.2); border: 2px solid #ffd700; border-radius: 10px;">
                <div style="font-size: 1.8rem; color: #ffd700;">🏆 ¡SUBISTE DE NIVEL!</div>
                <div style="font-size: 1.3rem; margin-top: 0.5rem;">Nivel ${levelUp.newLevel}</div>
                <div style="font-size: 1rem; margin-top: 0.5rem; color: #c0c0c0;">${levelUp.title}</div>
            </div>
        `;
    }
    
    detailsEl.innerHTML = detailsHTML;
    modal.style.display = 'block';
    
    setTimeout(() => {
        modal.querySelector('.custom-modal-content').style.animation = 'modalSlideIn 0.4s ease';
    }, 10);
    
    confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 }
    });
    
    if (levelUp) {
        setTimeout(() => {
            confetti({
                particleCount: 200,
                spread: 100,
                origin: { y: 0.6 },
                colors: ['#FFD700', '#FFA500', '#FF8C00']
            });
        }, 300);
    }
}

function closeReward() {
    const modal = document.getElementById('customReward');
    modal.style.display = 'none';
}

window.onclick = function(event) {
    const alertModal = document.getElementById('customAlert');
    const confirmModal = document.getElementById('customConfirm');
    const rewardModal = document.getElementById('customReward');
    
    if (event.target === alertModal) {
        closeAlert();
    }
    if (event.target === confirmModal) {
        closeConfirm(false);
    }
    if (event.target === rewardModal) {
        closeReward();
    }
}
