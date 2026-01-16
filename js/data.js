const TITLES = [
    { level: 1, title: "Aprendiz del Orden" },
    { level: 2, title: "Guardiana de la Cama Sagrada" },
    { level: 3, title: "Exploradora del Cuarto Perdido" },
    { level: 4, title: "Amiga de los Cepillos Valientes" },
    { level: 5, title: "Heroína del Agua Brillante" },
    { level: 6, title: "Ayudante del Gran Chef" },
    { level: 7, title: "Protectora de los Juguetes" },
    { level: 8, title: "Señora del Cajón Misterioso" },
    { level: 9, title: "Maestra de las Manos Limpias" },
    { level: 10, title: "Vigilante del Reino Doméstico" },
    { level: 11, title: "Arquitecta del Hogar Feliz" },
    { level: 12, title: "Portadora de la Toalla Legendaria" },
    { level: 13, title: "Defensora del Orden Secreto" },
    { level: 14, title: "Campeona del Buen Hábito" },
    { level: 15, title: "Dama de la Cocina Encantada" },
    { level: 16, title: "Custodia del Baño Reluciente" },
    { level: 17, title: "Guardián de las Cosas del Súper" },
    { level: 18, title: "Heroína del Día Completado" },
    { level: 19, title: "Maestra del Hogar Mágico" },
    { level: 20, title: "Gran Guardiana del Reino del Orden" }
];

const MISSIONS = [
    {
        id: 1,
        name: "Preparar el Campamento del Descanso",
        description: "Hacer la cama y dejarla lista para la próxima aventura",
        type: "diaria",
        xp: 3,
        gold: 15,
        icon: "🛏️",
        repeatable: true
    },
    {
        id: 2,
        name: "Salvar a los Juguetes Perdidos",
        description: "Recoger todos los juguetes y devolverlos a su hogar",
        type: "diaria",
        xp: 2,
        gold: 10,
        icon: "🧸",
        repeatable: true
    },
    {
        id: 3,
        name: "El Ritual del Cepillo Valiente",
        description: "Lavarse los dientes después de comer",
        type: "diaria",
        xp: 2,
        gold: 10,
        icon: "🪥",
        repeatable: true
    },
    {
        id: 4,
        name: "El Hechizo del Agua Brillante",
        description: "Lavarse las manos y la cara",
        type: "diaria",
        xp: 2,
        gold: 10,
        icon: "💧",
        repeatable: true
    },
    {
        id: 5,
        name: "Ordenar la Base Secreta",
        description: "Recoger el cuarto antes de dormir",
        type: "diaria",
        xp: 3,
        gold: 15,
        icon: "🏰",
        repeatable: true
    },
    {
        id: 6,
        name: "Despertar con Energía de Heroína",
        description: "Vestirse sola por la mañana",
        type: "diaria",
        xp: 3,
        gold: 15,
        icon: "👗",
        repeatable: true
    },
    {
        id: 7,
        name: "Cerrar el Portal del Desorden",
        description: "Recoger lo que has usado durante el día",
        type: "diaria",
        xp: 2,
        gold: 10,
        icon: "🚪",
        repeatable: true
    },
    {
        id: 8,
        name: "Ayudar al Gran Chef del Reino",
        description: "Ayudar a cocinar o preparar la comida",
        type: "ayuda",
        xp: 5,
        gold: 25,
        icon: "👨‍🍳",
        repeatable: true
    },
    {
        id: 9,
        name: "La Misión del Lavavajillas Mágico",
        description: "Sacar o meter platos en el lavavajillas",
        type: "ayuda",
        xp: 4,
        gold: 20,
        icon: "🍽️",
        repeatable: true
    },
    {
        id: 10,
        name: "Transportar los Tesoros del Súper",
        description: "Ayudar a meter las compras del supermercado",
        type: "ayuda",
        xp: 5,
        gold: 30,
        icon: "🛒",
        repeatable: true
    },
    {
        id: 11,
        name: "Doblar las Telas Encantadas",
        description: "Ayudar a doblar ropa limpia",
        type: "ayuda",
        xp: 4,
        gold: 20,
        icon: "👕",
        repeatable: true
    },
    {
        id: 12,
        name: "El Guardián del Cubo de la Basura",
        description: "Tirar la basura cuando toca",
        type: "ayuda",
        xp: 3,
        gold: 15,
        icon: "🗑️",
        repeatable: true
    },
    {
        id: 13,
        name: "Organizar el Altar de los Zapatos",
        description: "Colocar los zapatos en su sitio",
        type: "ayuda",
        xp: 3,
        gold: 15,
        icon: "👟",
        repeatable: true
    },
    {
        id: 14,
        name: "La Gran Limpieza del Reino",
        description: "Recoger el cuarto entero y dejarlo perfecto",
        type: "epica",
        xp: 10,
        gold: 50,
        icon: "✨",
        repeatable: true
    },
    {
        id: 15,
        name: "El Baño de las Burbujas Legendarias",
        description: "Ducharse sin protestar",
        type: "epica",
        xp: 8,
        gold: 40,
        icon: "🛁",
        repeatable: true
    },
    {
        id: 16,
        name: "Ayuda Extra al Consejo Familiar",
        description: "Ayudar en algo sin que te lo pidan",
        type: "epica",
        xp: 10,
        gold: 60,
        icon: "💝",
        repeatable: true
    },
    {
        id: 17,
        name: "El Día del Buen Comportamiento",
        description: "Cumplir todas las normas durante todo el día",
        type: "epica",
        xp: 12,
        gold: 70,
        icon: "🌟",
        repeatable: true
    },
    {
        id: 18,
        name: "Misión de la Sonrisa Valiente",
        description: "Hacer algo difícil sin enfadarse",
        type: "epica",
        xp: 8,
        gold: 45,
        icon: "😊",
        repeatable: true
    },
    {
        id: 19,
        name: "El Reto del Tiempo Mágico",
        description: "Hacer una tarea rápido y bien",
        type: "epica",
        xp: 8,
        gold: 40,
        icon: "⏰",
        repeatable: true
    },
    {
        id: 20,
        name: "La Jornada de la Heroína Completa",
        description: "Completar 5 misiones en un solo día",
        type: "epica",
        xp: 15,
        gold: 80,
        icon: "🏆",
        repeatable: true
    }
];

const REWARDS = [
    {
        id: 1,
        name: "Elegir el Postre del Día",
        description: "Tú eliges qué postre comer hoy",
        price: 50,
        category: "pequeña",
        icon: "🍦",
        requiredLevel: 1
    },
    {
        id: 2,
        name: "Elegir Dibujos Hoy",
        description: "Tú decides qué ver en la tele",
        price: 60,
        category: "pequeña",
        icon: "📺",
        requiredLevel: 1
    },
    {
        id: 3,
        name: "Elegir la Canción del Coche",
        description: "Poner tu música favorita en el coche",
        price: 50,
        category: "pequeña",
        icon: "🎵",
        requiredLevel: 1
    },
    {
        id: 4,
        name: "Tiempo Extra de Pintar",
        description: "15 minutos extra para dibujar o pintar",
        price: 70,
        category: "pequeña",
        icon: "🎨",
        requiredLevel: 2
    },
    {
        id: 5,
        name: "Elegir el Cuento",
        description: "Tú eliges qué cuento leer antes de dormir",
        price: 60,
        category: "pequeña",
        icon: "📖",
        requiredLevel: 2
    },
    {
        id: 6,
        name: "Dormir con un Peluche Extra",
        description: "Esta noche puedes llevar un peluche más a la cama",
        price: 80,
        category: "pequeña",
        icon: "🧸",
        requiredLevel: 3
    },
    {
        id: 7,
        name: "Cine en Casa",
        description: "Ver una película especial en familia",
        price: 200,
        category: "media",
        icon: "🎬",
        requiredLevel: 4
    },
    {
        id: 8,
        name: "Palomitas Especiales",
        description: "Hacer palomitas y comerlas viendo algo juntos",
        price: 150,
        category: "media",
        icon: "🍿",
        requiredLevel: 4
    },
    {
        id: 9,
        name: "Juego de Mesa en Familia",
        description: "Jugar al juego de mesa que tú elijas",
        price: 180,
        category: "media",
        icon: "🎲",
        requiredLevel: 5
    },
    {
        id: 10,
        name: "Baño con Espuma Extra",
        description: "Un baño especial con muchas burbujas y juguetes",
        price: 160,
        category: "media",
        icon: "🛁",
        requiredLevel: 5
    },
    {
        id: 11,
        name: "30 Minutos Extra de Juego",
        description: "Media hora más para jugar a lo que quieras",
        price: 200,
        category: "media",
        icon: "🎮",
        requiredLevel: 6
    },
    {
        id: 12,
        name: "Hacer Galletas Juntos",
        description: "Cocinar galletas especiales en familia",
        price: 220,
        category: "media",
        icon: "🍪",
        requiredLevel: 7
    },
    {
        id: 13,
        name: "Día de Capricho",
        description: "Un día donde tú decides muchas cosas",
        price: 350,
        category: "grande",
        icon: "🎉",
        requiredLevel: 8
    },
    {
        id: 14,
        name: "Elegir Merienda Especial",
        description: "Preparar una merienda que tú elijas",
        price: 300,
        category: "grande",
        icon: "🧁",
        requiredLevel: 9
    },
    {
        id: 15,
        name: "Sorpresa Misteriosa",
        description: "Una sorpresa que te va a encantar",
        price: 400,
        category: "grande",
        icon: "🎁",
        requiredLevel: 10
    },
    {
        id: 16,
        name: "Elegir Actividad del Fin de Semana",
        description: "Tú decides qué hacer el sábado o domingo",
        price: 380,
        category: "grande",
        icon: "🏰",
        requiredLevel: 12
    },
    {
        id: 17,
        name: "Elegir Algo Pequeño en la Tienda",
        description: "Comprar un juguete o cosa pequeña que te guste",
        price: 400,
        category: "grande",
        icon: "🛍️",
        requiredLevel: 14
    },
    {
        id: 18,
        name: "Fiesta en Casa",
        description: "Hacer una mini fiesta con música, baile y decoración",
        price: 350,
        category: "grande",
        icon: "🎈",
        requiredLevel: 15
    },
    {
        id: 19,
        name: "Día de la Reina del Hogar",
        description: "Un día entero especial donde eres la protagonista",
        price: 500,
        category: "epica",
        icon: "👑",
        requiredLevel: 17
    },
    {
        id: 20,
        name: "Evento Legendario Familiar",
        description: "Una excursión o plan súper especial en familia",
        price: 600,
        category: "epica",
        icon: "🌟",
        requiredLevel: 18
    }
];

function calculateXPForLevel(level) {
    return 5 + (level * 5);
}

function getTitleByLevel(level) {
    const title = TITLES.find(t => t.level === level);
    return title ? title.title : TITLES[0].title;
}

function getUnlockedRewards(level) {
    return REWARDS.filter(r => r.requiredLevel <= level);
}
