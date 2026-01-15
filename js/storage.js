// ============================================
// SISTEMA DE ALMACENAMIENTO - localStorage
// ============================================

const STORAGE_KEY = 'heroina_del_hogar_data';

// Datos por defecto del personaje
const DEFAULT_DATA = {
    personaje: {
        nombre: "Heroína",
        avatar: null, // base64 de la imagen
        nivel: 1,
        xp: 0,
        oro: 0,
        energia: 5
    },
    misionActiva: null, // { misionId, nombre, icono, fechaInicio }
    historial: {
        misionesCompletadas: [], // { misionId, fecha, xpGanada, oroGanado }
        recompensasCompradas: [], // { recompensaId, fecha, precioGastado }
        nivelesAlcanzados: [1] // historial de niveles
    },
    estadisticas: {
        totalMisiones: 0,
        totalXP: 0,
        totalOro: 0,
        totalGastado: 0,
        misionesHoy: 0,
        ultimaConexion: new Date().toISOString()
    }
};

// Guardar datos completos
function guardarDatos(datos) {
    try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(datos));
        return true;
    } catch (error) {
        console.error('Error al guardar datos:', error);
        return false;
    }
}

// Cargar datos
function cargarDatos() {
    try {
        const datos = localStorage.getItem(STORAGE_KEY);
        if (datos) {
            const datosParseados = JSON.parse(datos);
            // Actualizar última conexión
            datosParseados.estadisticas.ultimaConexion = new Date().toISOString();
            
            // Resetear misiones de hoy si es un nuevo día
            const hoy = new Date().toDateString();
            const ultimaMision = datosParseados.historial.misionesCompletadas[datosParseados.historial.misionesCompletadas.length - 1];
            if (ultimaMision && new Date(ultimaMision.fecha).toDateString() !== hoy) {
                datosParseados.estadisticas.misionesHoy = 0;
            }
            
            return datosParseados;
        }
        return { ...DEFAULT_DATA };
    } catch (error) {
        console.error('Error al cargar datos:', error);
        return { ...DEFAULT_DATA };
    }
}

// Reiniciar datos (borrar todo)
function reiniciarDatos() {
    try {
        localStorage.removeItem(STORAGE_KEY);
        return true;
    } catch (error) {
        console.error('Error al reiniciar datos:', error);
        return false;
    }
}

// Actualizar personaje
function actualizarPersonaje(campo, valor) {
    const datos = cargarDatos();
    datos.personaje[campo] = valor;
    return guardarDatos(datos);
}

// Añadir XP y oro
function añadirXPyOro(xp, oro) {
    const datos = cargarDatos();
    datos.personaje.xp += xp;
    datos.personaje.oro += oro;
    datos.estadisticas.totalXP += xp;
    datos.estadisticas.totalOro += oro;
    
    // Verificar si sube de nivel
    const nivelAnterior = datos.personaje.nivel;
    const { nuevoNivel, subioNivel } = verificarSubidaNivel(datos.personaje.nivel, datos.personaje.xp);
    
    if (subioNivel) {
        datos.personaje.nivel = nuevoNivel;
        datos.personaje.xp = 0; // Resetear XP al subir de nivel
        datos.historial.nivelesAlcanzados.push(nuevoNivel);
    }
    
    guardarDatos(datos);
    
    return {
        subioNivel,
        nivelAnterior,
        nivelNuevo: nuevoNivel,
        titulo: obtenerTituloPorNivel(nuevoNivel)
    };
}

// Verificar si debe subir de nivel
function verificarSubidaNivel(nivelActual, xpActual) {
    const xpNecesaria = calcularXPParaNivel(nivelActual);
    
    if (xpActual >= xpNecesaria) {
        return {
            subioNivel: true,
            nuevoNivel: nivelActual + 1
        };
    }
    
    return {
        subioNivel: false,
        nuevoNivel: nivelActual
    };
}

// Registrar misión completada
function registrarMisionCompletada(misionId, xp, oro) {
    const datos = cargarDatos();
    
    const registro = {
        misionId,
        fecha: new Date().toISOString(),
        xpGanada: xp,
        oroGanado: oro
    };
    
    datos.historial.misionesCompletadas.push(registro);
    datos.estadisticas.totalMisiones++;
    datos.estadisticas.misionesHoy++;
    
    guardarDatos(datos);
    
    return añadirXPyOro(xp, oro);
}

// Comprar recompensa
function comprarRecompensa(recompensaId, precio) {
    const datos = cargarDatos();
    
    if (datos.personaje.oro < precio) {
        return { exito: false, mensaje: "No tienes suficiente oro" };
    }
    
    datos.personaje.oro -= precio;
    datos.estadisticas.totalGastado += precio;
    
    const registro = {
        recompensaId,
        fecha: new Date().toISOString(),
        precioGastado: precio
    };
    
    datos.historial.recompensasCompradas.push(registro);
    
    guardarDatos(datos);
    
    return { exito: true, mensaje: "¡Recompensa comprada!" };
}

// Obtener estadísticas del día
function obtenerEstadisticasHoy() {
    const datos = cargarDatos();
    const hoy = new Date().toDateString();
    
    const misionesHoy = datos.historial.misionesCompletadas.filter(m => {
        return new Date(m.fecha).toDateString() === hoy;
    });
    
    const xpHoy = misionesHoy.reduce((sum, m) => sum + m.xpGanada, 0);
    const oroHoy = misionesHoy.reduce((sum, m) => sum + m.oroGanado, 0);
    
    return {
        misiones: misionesHoy.length,
        xp: xpHoy,
        oro: oroHoy
    };
}

// Obtener historial de recompensas compradas
function obtenerRecompensasCompradas() {
    const datos = cargarDatos();
    return datos.historial.recompensasCompradas;
}

// Verificar si una recompensa ya fue comprada (para items únicos)
function recompensaYaComprada(recompensaId) {
    const datos = cargarDatos();
    return datos.historial.recompensasCompradas.some(r => r.recompensaId === recompensaId);
}

// Iniciar misión
function iniciarMision(misionId, nombre, icono) {
    const datos = cargarDatos();
    
    // Si ya hay una misión activa, no permitir
    if (datos.misionActiva) {
        return { exito: false, mensaje: "Ya hay una misión en progreso" };
    }
    
    datos.misionActiva = {
        misionId,
        nombre,
        icono,
        fechaInicio: new Date().toISOString()
    };
    
    guardarDatos(datos);
    return { exito: true, mensaje: "Misión iniciada" };
}

// Cancelar misión activa
function cancelarMisionActiva() {
    const datos = cargarDatos();
    datos.misionActiva = null;
    guardarDatos(datos);
    return { exito: true, mensaje: "Misión cancelada" };
}

// Obtener misión activa
function obtenerMisionActiva() {
    const datos = cargarDatos();
    return datos.misionActiva;
}

// Completar misión activa
function completarMisionActiva() {
    const datos = cargarDatos();
    const misionActiva = datos.misionActiva;
    datos.misionActiva = null;
    guardarDatos(datos);
    return misionActiva;
}

// Exportar funciones
window.storage = {
    guardarDatos,
    cargarDatos,
    reiniciarDatos,
    actualizarPersonaje,
    añadirXPyOro,
    registrarMisionCompletada,
    comprarRecompensa,
    obtenerEstadisticasHoy,
    obtenerRecompensasCompradas,
    recompensaYaComprada,
    iniciarMision,
    cancelarMisionActiva,
    obtenerMisionActiva,
    completarMisionActiva
};
