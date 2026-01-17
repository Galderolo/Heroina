const CLASSES = [
    {
        id: 'paladin',
        name: 'Paladín',
        description: 'Defensor del hogar, resistente y valiente',
        icon: '🛡️',
        stats: {
            lives: 8,
            maxLives: 8,
            energy: 5,
            maxEnergy: 5
        }
    },
    {
        id: 'ranger',
        name: 'Ranger',
        description: 'Explorador ágil y energético',
        icon: '🏹',
        stats: {
            lives: 5,
            maxLives: 5,
            energy: 8,
            maxEnergy: 8
        }
    },
    {
        id: 'mage',
        name: 'Mago',
        description: 'Estudioso del orden, equilibrado y sabio',
        icon: '🔮',
        stats: {
            lives: 6,
            maxLives: 6,
            energy: 6,
            maxEnergy: 6
        }
    },
    {
        id: 'warrior',
        name: 'Guerrero',
        description: 'Luchador fuerte, vidas altas y energía media',
        icon: '⚔️',
        stats: {
            lives: 7,
            maxLives: 7,
            energy: 5,
            maxEnergy: 5
        }
    }
];

const TITLES = [
    { level: 1, title: "Novato Doméstico" },
    { level: 2, title: "Aprendiz del Orden" },
    { level: 3, title: "Iniciado de las Tareas" },
    { level: 4, title: "Guardián Junior" },
    { level: 5, title: "Escudero del Hogar" },
    { level: 6, title: "Caballero de la Limpieza" },
    { level: 7, title: "Paladín de las Tareas" },
    { level: 8, title: "Señor de la Organización" },
    { level: 9, title: "Campeón del Orden" },
    { level: 10, title: "Maestro de las Rutinas" },
    { level: 11, title: "Comandante del Hogar" },
    { level: 12, title: "Guardián Real" },
    { level: 13, title: "Protector Épico" },
    { level: 14, title: "Campeón Legendario" },
    { level: 15, title: "Héroe del Dominio" },
    { level: 16, title: "Guardián Supremo" },
    { level: 17, title: "Gran Maestro" },
    { level: 18, title: "Señor de la Guerra Doméstica" },
    { level: 19, title: "Leyenda del Orden" },
    { level: 20, title: "Titán del Hogar Perfecto" }
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
        id: 21,
        name: "El banquete mágico",
        description: "Termina la comida que te han puesto en el almuerzo o la cena",
        type: "diaria",
        xp: 3,
        gold: 15,
        icon: "🍳",
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
        name: "La Defensora de la Paz Familiar",
        description: "Pasar todo el día sin rabietas ni conflictos",
        type: "epica",
        xp: 12,
        gold: 75,
        icon: "🕊️",
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
        requiredLevel: 1
    },
    {
        id: 5,
        name: "Elegir el Cuento",
        description: "Tú eliges qué cuento leer antes de dormir",
        price: 60,
        category: "pequeña",
        icon: "📖",
        requiredLevel: 1
    },
    {
        id: 6,
        name: "Dormir con un Peluche Extra",
        description: "Esta noche puedes llevar un peluche más a la cama",
        price: 80,
        category: "pequeña",
        icon: "🧸",
        requiredLevel: 1
    },
    {
        id: 7,
        name: "Cine en Casa",
        description: "Ver una película especial en familia",
        price: 200,
        category: "media",
        icon: "🎬",
        requiredLevel: 1
    },
    {
        id: 8,
        name: "Palomitas Especiales",
        description: "Hacer palomitas y comerlas viendo algo juntos",
        price: 150,
        category: "media",
        icon: "🍿",
        requiredLevel: 1
    },
    {
        id: 9,
        name: "Juego de Mesa en Familia",
        description: "Jugar al juego de mesa que tú elijas",
        price: 180,
        category: "media",
        icon: "🎲",
        requiredLevel: 1
    },
    {
        id: 10,
        name: "Baño con Espuma Extra",
        description: "Un baño especial con muchas burbujas y juguetes",
        price: 160,
        category: "media",
        icon: "🛁",
        requiredLevel: 1
    },
    {
        id: 11,
        name: "30 Minutos Extra de Juego",
        description: "Media hora más para jugar a lo que quieras",
        price: 200,
        category: "media",
        icon: "🎮",
        requiredLevel: 1
    },
    {
        id: 12,
        name: "Hacer Galletas Juntos",
        description: "Cocinar galletas especiales en familia",
        price: 220,
        category: "media",
        icon: "🍪",
        requiredLevel: 1
    },
    {
        id: 13,
        name: "Día de Capricho",
        description: "Un día donde tú decides muchas cosas",
        price: 350,
        category: "grande",
        icon: "🎉",
        requiredLevel: 1
    },
    {
        id: 14,
        name: "Elegir Merienda Especial",
        description: "Preparar una merienda que tú elijas",
        price: 300,
        category: "grande",
        icon: "🧁",
        requiredLevel: 1
    },
    {
        id: 15,
        name: "Sorpresa Misteriosa",
        description: "Una sorpresa que te va a encantar",
        price: 400,
        category: "grande",
        icon: "🎁",
        requiredLevel: 1
    },
    {
        id: 16,
        name: "Elegir Actividad del Fin de Semana",
        description: "Tú decides qué hacer el sábado o domingo",
        price: 380,
        category: "grande",
        icon: "🏰",
        requiredLevel: 1
    },
    {
        id: 17,
        name: "Elegir Algo Pequeño en la Tienda",
        description: "Comprar un juguete o cosa pequeña que te guste",
        price: 400,
        category: "grande",
        icon: "🛍️",
        requiredLevel: 1
    },
    {
        id: 18,
        name: "Fiesta en Casa",
        description: "Hacer una mini fiesta con música, baile y decoración",
        price: 350,
        category: "grande",
        icon: "🎈",
        requiredLevel: 1
    },
    {
        id: 19,
        name: "Día de la Reina del Hogar",
        description: "Un día entero especial donde eres la protagonista",
        price: 500,
        category: "epica",
        icon: "👑",
        requiredLevel: 1
    },
    {
        id: 20,
        name: "Evento Legendario Familiar",
        description: "Una excursión o plan súper especial en familia",
        price: 600,
        category: "epica",
        icon: "🌟",
        requiredLevel: 1
    },
    {
        id: 21,
        name: "Poción de Vida Menor",
        description: "Restaura 1 corazón de vida",
        price: 100,
        category: "potion",
        icon: "🧪",
        requiredLevel: 1,
        effect: "restoreLife",
        value: 1
    },
    {
        id: 22,
        name: "Super Poción",
        description: "Restaura 2 corazones de vida",
        price: 200,
        category: "potion",
        icon: "⚗️",
        requiredLevel: 1,
        effect: "restoreLife",
        value: 2
    },
    {
        id: 23,
        name: "Poción de Energía",
        description: "Restaura 2 puntos de energía",
        price: 120,
        category: "potion",
        icon: "⚡",
        requiredLevel: 1,
        effect: "restoreEnergy",
        value: 2
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
