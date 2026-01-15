// ============================================
// LÓGICA PRINCIPAL DEL JUEGO
// ============================================

// Estado global del juego
let gameState = null;

// Inicializar el juego
function inicializarJuego() {
    gameState = window.storage.cargarDatos();
    return gameState;
}

// Obtener estado actual
function obtenerEstado() {
    if (!gameState) {
        inicializarJuego();
    }
    return gameState;
}

// Configurar personaje (primera vez)
function configurarPersonaje(nombre, avatarBase64 = null) {
    window.storage.actualizarPersonaje('nombre', nombre);
    if (avatarBase64) {
        window.storage.actualizarPersonaje('avatar', avatarBase64);
    }
    gameState = window.storage.cargarDatos();
    return gameState;
}

// Iniciar misión
function iniciarMision(misionId) {
    const mision = MISIONES.find(m => m.id === misionId);
    
    if (!mision) {
        return { exito: false, mensaje: "Misión no encontrada" };
    }
    
    // Verificar energía suficiente
    if (!window.storage.tieneSuficienteEnergia()) {
        return { 
            exito: false, 
            mensaje: "No tienes suficiente energía (necesitas 2 ❤️). Espera a mañana o sube de nivel para recuperarla." 
        };
    }
    
    const resultado = window.storage.iniciarMision(misionId, mision.nombre, mision.icono);
    
    if (!resultado.exito) {
        return resultado;
    }
    
    gameState = window.storage.cargarDatos();
    
    return {
        exito: true,
        mision,
        mensaje: "Misión iniciada"
    };
}

// Cancelar misión activa
function cancelarMisionActiva() {
    const resultado = window.storage.cancelarMisionActiva();
    gameState = window.storage.cargarDatos();
    return resultado;
}

// Obtener misión activa
function obtenerMisionActiva() {
    return window.storage.obtenerMisionActiva();
}

// Completar misión (ahora completa la misión activa)
function completarMisionActiva() {
    const misionActiva = window.storage.obtenerMisionActiva();
    
    if (!misionActiva) {
        return { exito: false, mensaje: "No hay ninguna misión en progreso" };
    }
    
    const mision = MISIONES.find(m => m.id === misionActiva.misionId);
    
    if (!mision) {
        return { exito: false, mensaje: "Misión no encontrada" };
    }
    
    // Marcar como completada
    window.storage.completarMisionActiva();
    const resultado = window.storage.registrarMisionCompletada(mision.id, mision.xp, mision.oro);
    gameState = window.storage.cargarDatos();
    
    return {
        exito: true,
        mision,
        xpGanada: mision.xp,
        oroGanado: mision.oro,
        subioNivel: resultado.subioNivel,
        nivelNuevo: resultado.nivelNuevo,
        titulo: resultado.titulo
    };
}

// Comprar recompensa de la tienda
function comprarRecompensa(recompensaId) {
    const recompensa = RECOMPENSAS.find(r => r.id === recompensaId);
    
    if (!recompensa) {
        return { exito: false, mensaje: "Recompensa no encontrada" };
    }
    
    const estado = obtenerEstado();
    
    // Verificar nivel requerido
    if (estado.personaje.nivel < recompensa.nivelRequerido) {
        return { 
            exito: false, 
            mensaje: `Necesitas nivel ${recompensa.nivelRequerido} para desbloquear esto` 
        };
    }
    
    const resultado = window.storage.comprarRecompensa(recompensaId, recompensa.precio);
    
    if (resultado.exito) {
        gameState = window.storage.cargarDatos();
        return {
            exito: true,
            recompensa,
            mensaje: "¡Recompensa comprada con éxito!"
        };
    }
    
    return resultado;
}

// Obtener progreso de nivel (porcentaje)
function obtenerProgresoNivel() {
    const estado = obtenerEstado();
    const xpNecesaria = calcularXPParaNivel(estado.personaje.nivel);
    const progreso = (estado.personaje.xp / xpNecesaria) * 100;
    
    return {
        xpActual: estado.personaje.xp,
        xpNecesaria,
        porcentaje: Math.min(progreso, 100),
        nivel: estado.personaje.nivel
    };
}

// Obtener misiones disponibles según tipo
function obtenerMisionesPorTipo(tipo = null) {
    if (tipo) {
        return MISIONES.filter(m => m.tipo === tipo);
    }
    return MISIONES;
}

// Obtener recompensas disponibles según nivel
function obtenerRecompensasDisponibles() {
    const estado = obtenerEstado();
    return RECOMPENSAS.map(r => ({
        ...r,
        desbloqueada: estado.personaje.nivel >= r.nivelRequerido,
        puedeComprar: estado.personaje.oro >= r.precio && estado.personaje.nivel >= r.nivelRequerido
    }));
}

// Obtener misiones completadas hoy
function obtenerMisionesHoy() {
    const hoy = new Date().toDateString();
    const estado = obtenerEstado();
    
    return estado.historial.misionesCompletadas.filter(m => {
        return new Date(m.fecha).toDateString() === hoy;
    });
}

// Calcular racha (días consecutivos con misiones)
function calcularRacha() {
    const estado = obtenerEstado();
    const misiones = estado.historial.misionesCompletadas;
    
    if (misiones.length === 0) return 0;
    
    let racha = 1;
    let diaActual = new Date();
    diaActual.setHours(0, 0, 0, 0);
    
    for (let i = misiones.length - 1; i >= 0; i--) {
        const fechaMision = new Date(misiones[i].fecha);
        fechaMision.setHours(0, 0, 0, 0);
        
        const diferenciaDias = Math.floor((diaActual - fechaMision) / (1000 * 60 * 60 * 24));
        
        if (diferenciaDias === 1) {
            racha++;
            diaActual = fechaMision;
        } else if (diferenciaDias > 1) {
            break;
        }
    }
    
    return racha;
}

// Reiniciar juego (con confirmación)
function reiniciarJuego() {
    const confirmacion = confirm('¿Estás seguro de que quieres reiniciar todo el progreso? Esta acción no se puede deshacer.');
    
    if (confirmacion) {
        window.storage.reiniciarDatos();
        gameState = window.storage.cargarDatos();
        return { exito: true, mensaje: "Juego reiniciado" };
    }
    
    return { exito: false, mensaje: "Reinicio cancelado" };
}

// Exportar imagen del avatar
function subirAvatar(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        
        reader.onload = (e) => {
            const avatarBase64 = e.target.result;
            window.storage.actualizarPersonaje('avatar', avatarBase64);
            gameState = window.storage.cargarDatos();
            resolve(avatarBase64);
        };
        
        reader.onerror = (error) => {
            reject(error);
        };
        
        reader.readAsDataURL(file);
    });
}

// Obtener resumen del personaje
function obtenerResumenPersonaje() {
    const estado = obtenerEstado();
    const progreso = obtenerProgresoNivel();
    const titulo = obtenerTituloPorNivel(estado.personaje.nivel);
    const estadisticasHoy = window.storage.obtenerEstadisticasHoy();
    const racha = calcularRacha();
    
    return {
        ...estado.personaje,
        titulo,
        progreso,
        estadisticasHoy,
        racha,
        totalMisiones: estado.estadisticas.totalMisiones,
        totalGastado: estado.estadisticas.totalGastado
    };
}

// Exportar funciones globales
window.game = {
    inicializarJuego,
    obtenerEstado,
    configurarPersonaje,
    iniciarMision,
    cancelarMisionActiva,
    obtenerMisionActiva,
    completarMisionActiva,
    comprarRecompensa,
    obtenerProgresoNivel,
    obtenerMisionesPorTipo,
    obtenerRecompensasDisponibles,
    obtenerMisionesHoy,
    calcularRacha,
    reiniciarJuego,
    subirAvatar,
    obtenerResumenPersonaje
};

// Auto-inicializar al cargar
document.addEventListener('DOMContentLoaded', () => {
    inicializarJuego();
});
