// ============================================
// DATOS DEL JUEGO - SISTEMA DE GAMIFICACIÓN
// ============================================

// 20 TÍTULOS DEL PERSONAJE
const TITULOS = [
    { nivel: 1, titulo: "Aprendiz del Orden" },
    { nivel: 2, titulo: "Guardiana de la Cama Sagrada" },
    { nivel: 3, titulo: "Exploradora del Cuarto Perdido" },
    { nivel: 4, titulo: "Amiga de los Cepillos Valientes" },
    { nivel: 5, titulo: "Heroína del Agua Brillante" },
    { nivel: 6, titulo: "Ayudante del Gran Chef" },
    { nivel: 7, titulo: "Protectora de los Juguetes" },
    { nivel: 8, titulo: "Señora del Cajón Misterioso" },
    { nivel: 9, titulo: "Maestra de las Manos Limpias" },
    { nivel: 10, titulo: "Vigilante del Reino Doméstico" },
    { nivel: 11, titulo: "Arquitecta del Hogar Feliz" },
    { nivel: 12, titulo: "Portadora de la Toalla Legendaria" },
    { nivel: 13, titulo: "Defensora del Orden Secreto" },
    { nivel: 14, titulo: "Campeona del Buen Hábito" },
    { nivel: 15, titulo: "Dama de la Cocina Encantada" },
    { nivel: 16, titulo: "Custodia del Baño Reluciente" },
    { nivel: 17, titulo: "Guardián de las Cosas del Súper" },
    { nivel: 18, titulo: "Heroína del Día Completado" },
    { nivel: 19, titulo: "Maestra del Hogar Mágico" },
    { nivel: 20, titulo: "Gran Guardiana del Reino del Orden" }
];

// 20 MISIONES NARRATIVAS
const MISIONES = [
    // MISIONES DIARIAS (Verde)
    {
        id: 1,
        nombre: "Preparar el Campamento del Descanso",
        descripcion: "Hacer la cama y dejarla lista para la próxima aventura",
        tipo: "diaria",
        xp: 3,
        oro: 15,
        icono: "🛏️",
        repetible: true
    },
    {
        id: 2,
        nombre: "Salvar a los Juguetes Perdidos",
        descripcion: "Recoger todos los juguetes y devolverlos a su hogar",
        tipo: "diaria",
        xp: 2,
        oro: 10,
        icono: "🧸",
        repetible: true
    },
    {
        id: 3,
        nombre: "El Ritual del Cepillo Valiente",
        descripcion: "Lavarse los dientes después de comer",
        tipo: "diaria",
        xp: 2,
        oro: 10,
        icono: "🪥",
        repetible: true
    },
    {
        id: 4,
        nombre: "El Hechizo del Agua Brillante",
        descripcion: "Lavarse las manos y la cara",
        tipo: "diaria",
        xp: 2,
        oro: 10,
        icono: "💧",
        repetible: true
    },
    {
        id: 5,
        nombre: "Ordenar la Base Secreta",
        descripcion: "Recoger el cuarto antes de dormir",
        tipo: "diaria",
        xp: 3,
        oro: 15,
        icono: "🏰",
        repetible: true
    },
    {
        id: 6,
        nombre: "Despertar con Energía de Heroína",
        descripcion: "Vestirse sola por la mañana",
        tipo: "diaria",
        xp: 3,
        oro: 15,
        icono: "👗",
        repetible: true
    },
    {
        id: 7,
        nombre: "Cerrar el Portal del Desorden",
        descripcion: "Recoger lo que has usado durante el día",
        tipo: "diaria",
        xp: 2,
        oro: 10,
        icono: "🚪",
        repetible: true
    },
    
    // MISIONES DE AYUDA (Azul)
    {
        id: 8,
        nombre: "Ayudar al Gran Chef del Reino",
        descripcion: "Ayudar a cocinar o preparar la comida",
        tipo: "ayuda",
        xp: 5,
        oro: 25,
        icono: "👨‍🍳",
        repetible: true
    },
    {
        id: 9,
        nombre: "La Misión del Lavavajillas Mágico",
        descripcion: "Sacar o meter platos en el lavavajillas",
        tipo: "ayuda",
        xp: 4,
        oro: 20,
        icono: "🍽️",
        repetible: true
    },
    {
        id: 10,
        nombre: "Transportar los Tesoros del Súper",
        descripcion: "Ayudar a meter las compras del supermercado",
        tipo: "ayuda",
        xp: 5,
        oro: 30,
        icono: "🛒",
        repetible: true
    },
    {
        id: 11,
        nombre: "Doblar las Telas Encantadas",
        descripcion: "Ayudar a doblar ropa limpia",
        tipo: "ayuda",
        xp: 4,
        oro: 20,
        icono: "👕",
        repetible: true
    },
    {
        id: 12,
        nombre: "El Guardián del Cubo de la Basura",
        descripcion: "Tirar la basura cuando toca",
        tipo: "ayuda",
        xp: 3,
        oro: 15,
        icono: "🗑️",
        repetible: true
    },
    {
        id: 13,
        nombre: "Organizar el Altar de los Zapatos",
        descripcion: "Colocar los zapatos en su sitio",
        tipo: "ayuda",
        xp: 3,
        oro: 15,
        icono: "👟",
        repetible: true
    },
    
    // MISIONES ESPECIALES / ÉPICAS (Morado)
    {
        id: 14,
        nombre: "La Gran Limpieza del Reino",
        descripcion: "Recoger el cuarto entero y dejarlo perfecto",
        tipo: "epica",
        xp: 10,
        oro: 50,
        icono: "✨",
        repetible: true
    },
    {
        id: 15,
        nombre: "El Baño de las Burbujas Legendarias",
        descripcion: "Ducharse sin protestar",
        tipo: "epica",
        xp: 8,
        oro: 40,
        icono: "🛁",
        repetible: true
    },
    {
        id: 16,
        nombre: "Ayuda Extra al Consejo Familiar",
        descripcion: "Ayudar en algo sin que te lo pidan",
        tipo: "epica",
        xp: 10,
        oro: 60,
        icono: "💝",
        repetible: true
    },
    {
        id: 17,
        nombre: "El Día del Buen Comportamiento",
        descripcion: "Cumplir todas las normas durante todo el día",
        tipo: "epica",
        xp: 12,
        oro: 70,
        icono: "🌟",
        repetible: true
    },
    {
        id: 18,
        nombre: "Misión de la Sonrisa Valiente",
        descripcion: "Hacer algo difícil sin enfadarse",
        tipo: "epica",
        xp: 8,
        oro: 45,
        icono: "😊",
        repetible: true
    },
    {
        id: 19,
        nombre: "El Reto del Tiempo Mágico",
        descripcion: "Hacer una tarea rápido y bien",
        tipo: "epica",
        xp: 8,
        oro: 40,
        icono: "⏰",
        repetible: true
    },
    {
        id: 20,
        nombre: "La Jornada de la Heroína Completa",
        descripcion: "Completar 5 misiones en un solo día",
        tipo: "epica",
        xp: 15,
        oro: 80,
        icono: "🏆",
        repetible: true
    }
];

// 20 RECOMPENSAS DE LA TIENDA
const RECOMPENSAS = [
    // RECOMPENSAS PEQUEÑAS (50-100 oro)
    {
        id: 1,
        nombre: "Elegir el Postre del Día",
        descripcion: "Tú eliges qué postre comer hoy",
        precio: 50,
        categoria: "pequeña",
        icono: "🍦",
        nivelRequerido: 1
    },
    {
        id: 2,
        nombre: "Elegir Dibujos Hoy",
        descripcion: "Tú decides qué ver en la tele",
        precio: 60,
        categoria: "pequeña",
        icono: "📺",
        nivelRequerido: 1
    },
    {
        id: 3,
        nombre: "Elegir la Canción del Coche",
        descripcion: "Poner tu música favorita en el coche",
        precio: 50,
        categoria: "pequeña",
        icono: "🎵",
        nivelRequerido: 1
    },
    {
        id: 4,
        nombre: "Tiempo Extra de Pintar",
        descripcion: "15 minutos extra para dibujar o pintar",
        precio: 70,
        categoria: "pequeña",
        icono: "🎨",
        nivelRequerido: 2
    },
    {
        id: 5,
        nombre: "Elegir el Cuento",
        descripcion: "Tú eliges qué cuento leer antes de dormir",
        precio: 60,
        categoria: "pequeña",
        icono: "📖",
        nivelRequerido: 2
    },
    {
        id: 6,
        nombre: "Dormir con un Peluche Extra",
        descripcion: "Esta noche puedes llevar un peluche más a la cama",
        precio: 80,
        categoria: "pequeña",
        icono: "🧸",
        nivelRequerido: 3
    },
    
    // RECOMPENSAS MEDIAS (150-250 oro)
    {
        id: 7,
        nombre: "Cine en Casa",
        descripcion: "Ver una película especial en familia",
        precio: 200,
        categoria: "media",
        icono: "🎬",
        nivelRequerido: 4
    },
    {
        id: 8,
        nombre: "Palomitas Especiales",
        descripcion: "Hacer palomitas y comerlas viendo algo juntos",
        precio: 150,
        categoria: "media",
        icono: "🍿",
        nivelRequerido: 4
    },
    {
        id: 9,
        nombre: "Juego de Mesa en Familia",
        descripcion: "Jugar al juego de mesa que tú elijas",
        precio: 180,
        categoria: "media",
        icono: "🎲",
        nivelRequerido: 5
    },
    {
        id: 10,
        nombre: "Baño con Espuma Extra",
        descripcion: "Un baño especial con muchas burbujas y juguetes",
        precio: 160,
        categoria: "media",
        icono: "🛁",
        nivelRequerido: 5
    },
    {
        id: 11,
        nombre: "30 Minutos Extra de Juego",
        descripcion: "Media hora más para jugar a lo que quieras",
        precio: 200,
        categoria: "media",
        icono: "🎮",
        nivelRequerido: 6
    },
    {
        id: 12,
        nombre: "Hacer Galletas Juntos",
        descripcion: "Cocinar galletas especiales en familia",
        precio: 220,
        categoria: "media",
        icono: "🍪",
        nivelRequerido: 7
    },
    
    // RECOMPENSAS GRANDES (300-400 oro)
    {
        id: 13,
        nombre: "Día de Capricho",
        descripcion: "Un día donde tú decides muchas cosas",
        precio: 350,
        categoria: "grande",
        icono: "🎉",
        nivelRequerido: 8
    },
    {
        id: 14,
        nombre: "Elegir Merienda Especial",
        descripcion: "Preparar una merienda que tú elijas",
        precio: 300,
        categoria: "grande",
        icono: "🧁",
        nivelRequerido: 9
    },
    {
        id: 15,
        nombre: "Sorpresa Misteriosa",
        descripcion: "Una sorpresa que te va a encantar",
        precio: 400,
        categoria: "grande",
        icono: "🎁",
        nivelRequerido: 10
    },
    {
        id: 16,
        nombre: "Elegir Actividad del Fin de Semana",
        descripcion: "Tú decides qué hacer el sábado o domingo",
        precio: 380,
        categoria: "grande",
        icono: "🏰",
        nivelRequerido: 12
    },
    {
        id: 17,
        nombre: "Elegir Algo Pequeño en la Tienda",
        descripcion: "Comprar un juguete o cosa pequeña que te guste",
        precio: 400,
        categoria: "grande",
        icono: "🛍️",
        nivelRequerido: 14
    },
    {
        id: 18,
        nombre: "Fiesta en Casa",
        descripcion: "Hacer una mini fiesta con música, baile y decoración",
        precio: 350,
        categoria: "grande",
        icono: "🎈",
        nivelRequerido: 15
    },
    
    // RECOMPENSAS ÉPICAS (500+ oro)
    {
        id: 19,
        nombre: "Día de la Reina del Hogar",
        descripcion: "Un día entero especial donde eres la protagonista",
        precio: 500,
        categoria: "epica",
        icono: "👑",
        nivelRequerido: 17
    },
    {
        id: 20,
        nombre: "Evento Legendario Familiar",
        descripcion: "Una excursión o plan súper especial en familia",
        precio: 600,
        categoria: "epica",
        icono: "🌟",
        nivelRequerido: 18
    }
];

// Función para calcular XP necesaria para subir de nivel
function calcularXPParaNivel(nivel) {
    // Nivel 1→2: 10 XP, luego +5 XP por cada nivel
    return 5 + (nivel * 5);
}

// Función para obtener título según nivel
function obtenerTituloPorNivel(nivel) {
    const titulo = TITULOS.find(t => t.nivel === nivel);
    return titulo ? titulo.titulo : TITULOS[0].titulo;
}

// Función para obtener recompensas desbloqueadas según nivel
function obtenerRecompensasDesbloqueadas(nivel) {
    return RECOMPENSAS.filter(r => r.nivelRequerido <= nivel);
}
