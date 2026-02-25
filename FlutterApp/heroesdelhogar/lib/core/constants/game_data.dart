import '../../domain/models/character_class.dart';
import '../../domain/models/mission.dart';
import '../../domain/models/reward.dart';

/// Clases de personaje disponibles.
const List<CharacterClass> kClasses = [
  CharacterClass(
    id: 'paladin',
    name: 'Paladin',
    description: 'Defensor del hogar, resistente y valiente',
    icon: '\u{1F6E1}\u{FE0F}',
    lives: 8,
    maxLives: 8,
    energy: 5,
    maxEnergy: 5,
  ),
  CharacterClass(
    id: 'ranger',
    name: 'Ranger',
    description: 'Explorador agil y energetico',
    icon: '\u{1F3F9}',
    lives: 5,
    maxLives: 5,
    energy: 8,
    maxEnergy: 8,
  ),
  CharacterClass(
    id: 'mage',
    name: 'Mago',
    description: 'Estudioso del orden, equilibrado y sabio',
    icon: '\u{1F52E}',
    lives: 6,
    maxLives: 6,
    energy: 6,
    maxEnergy: 6,
  ),
  CharacterClass(
    id: 'warrior',
    name: 'Guerrero',
    description: 'Luchador fuerte, vidas altas y energia media',
    icon: '\u{2694}\u{FE0F}',
    lives: 7,
    maxLives: 7,
    energy: 5,
    maxEnergy: 5,
  ),
];

/// Titulos por nivel (1-20).
const List<({int level, String title})> kTitles = [
  (level: 1, title: 'Novato Domestico'),
  (level: 2, title: 'Aprendiz del Orden'),
  (level: 3, title: 'Iniciado de las Tareas'),
  (level: 4, title: 'Guardian Junior'),
  (level: 5, title: 'Escudero del Hogar'),
  (level: 6, title: 'Caballero de la Limpieza'),
  (level: 7, title: 'Paladin de las Tareas'),
  (level: 8, title: 'Senor de la Organizacion'),
  (level: 9, title: 'Campeon del Orden'),
  (level: 10, title: 'Maestro de las Rutinas'),
  (level: 11, title: 'Comandante del Hogar'),
  (level: 12, title: 'Guardian Real'),
  (level: 13, title: 'Protector Epico'),
  (level: 14, title: 'Campeon Legendario'),
  (level: 15, title: 'Heroe del Dominio'),
  (level: 16, title: 'Guardian Supremo'),
  (level: 17, title: 'Gran Maestro'),
  (level: 18, title: 'Senor de la Guerra Domestica'),
  (level: 19, title: 'Leyenda del Orden'),
  (level: 20, title: 'Titan del Hogar Perfecto'),
];

/// Misiones base del juego.
const List<Mission> kMissions = [
  // --- Diarias ---
  Mission(
      id: 1,
      name: 'Preparar el Campamento del Descanso',
      description: 'Hacer la cama y dejarla lista para la proxima aventura',
      type: MissionType.diaria,
      xp: 3,
      gold: 18,
      icon: '\u{1F6CF}\u{FE0F}'),
  Mission(
      id: 2,
      name: 'Salvar a los Juguetes Perdidos',
      description: 'Recoger todos los juguetes y devolverlos a su hogar',
      type: MissionType.diaria,
      xp: 2,
      gold: 15,
      icon: '\u{1F9F8}'),
  Mission(
      id: 3,
      name: 'El Ritual del Cepillo Valiente',
      description: 'Lavarse los dientes despues de comer',
      type: MissionType.diaria,
      xp: 2,
      gold: 15,
      icon: '\u{1FAA5}'),
  Mission(
      id: 4,
      name: 'El Hechizo del Agua Brillante',
      description: 'Lavarse las manos y la cara',
      type: MissionType.diaria,
      xp: 2,
      gold: 15,
      icon: '\u{1F4A7}'),
  Mission(
      id: 5,
      name: 'Ordenar la Base Secreta',
      description: 'Recoger el cuarto antes de dormir',
      type: MissionType.diaria,
      xp: 3,
      gold: 20,
      icon: '\u{1F3F0}'),
  Mission(
      id: 21,
      name: 'El banquete magico',
      description:
          'Termina la comida que te han puesto en el almuerzo o la cena',
      type: MissionType.diaria,
      xp: 3,
      gold: 18,
      icon: '\u{1F373}'),
  Mission(
      id: 6,
      name: 'Despertar con Energia de Heroina',
      description: 'Vestirse sola por la manana',
      type: MissionType.diaria,
      xp: 3,
      gold: 18,
      icon: '\u{1F457}'),
  Mission(
      id: 7,
      name: 'Cerrar el Portal del Desorden',
      description: 'Recoger lo que has usado durante el dia',
      type: MissionType.diaria,
      xp: 2,
      gold: 15,
      icon: '\u{1F6AA}'),
  Mission(
      id: 22,
      name: 'El Fruto de la Vitalidad',
      description: 'Comer una pieza de fruta',
      type: MissionType.diaria,
      xp: 3,
      gold: 18,
      icon: '\u{1F34E}'),

  // --- Ayuda ---
  Mission(
      id: 8,
      name: 'Ayudar al Gran Chef del Reino',
      description: 'Ayudar a cocinar o preparar la comida',
      type: MissionType.ayuda,
      xp: 5,
      gold: 25,
      icon: '\u{1F468}\u{200D}\u{1F373}'),
  Mission(
      id: 9,
      name: 'La Mision del Lavavajillas Magico',
      description: 'Sacar o meter platos en el lavavajillas',
      type: MissionType.ayuda,
      xp: 4,
      gold: 20,
      icon: '\u{1F37D}\u{FE0F}'),
  Mission(
      id: 10,
      name: 'Transportar los Tesoros del Super',
      description: 'Ayudar a meter las compras del supermercado',
      type: MissionType.ayuda,
      xp: 5,
      gold: 30,
      icon: '\u{1F6D2}'),
  Mission(
      id: 11,
      name: 'Doblar las Telas Encantadas',
      description: 'Ayudar a doblar ropa limpia',
      type: MissionType.ayuda,
      xp: 4,
      gold: 20,
      icon: '\u{1F455}'),
  Mission(
      id: 12,
      name: 'El Guardian del Cubo de la Basura',
      description: 'Tirar la basura cuando toca',
      type: MissionType.ayuda,
      xp: 3,
      gold: 20,
      icon: '\u{1F5D1}\u{FE0F}'),
  Mission(
      id: 13,
      name: 'Organizar el Altar de los Zapatos',
      description: 'Colocar los zapatos en su sitio',
      type: MissionType.ayuda,
      xp: 3,
      gold: 20,
      icon: '\u{1F45F}'),

  // --- Epicas ---
  Mission(
      id: 14,
      name: 'La Gran Limpieza del Reino',
      description: 'Recoger el cuarto entero y dejarlo perfecto',
      type: MissionType.epica,
      xp: 10,
      gold: 50,
      icon: '\u{2728}'),
  Mission(
      id: 15,
      name: 'El Bano de las Burbujas Legendarias',
      description: 'Ducharse sin protestar',
      type: MissionType.epica,
      xp: 8,
      gold: 40,
      icon: '\u{1F6C1}'),
  Mission(
      id: 16,
      name: 'Ayuda Extra al Consejo Familiar',
      description: 'Ayudar en algo sin que te lo pidan',
      type: MissionType.epica,
      xp: 10,
      gold: 60,
      icon: '\u{1F49D}'),
  Mission(
      id: 17,
      name: 'El Dia del Buen Comportamiento',
      description: 'Cumplir todas las normas durante todo el dia',
      type: MissionType.epica,
      xp: 12,
      gold: 70,
      icon: '\u{1F31F}'),
  Mission(
      id: 18,
      name: 'Mision de la Sonrisa Valiente',
      description: 'Hacer algo dificil sin enfadarse',
      type: MissionType.epica,
      xp: 8,
      gold: 45,
      icon: '\u{1F60A}'),
  Mission(
      id: 19,
      name: 'El Reto del Tiempo Magico',
      description: 'Hacer una tarea rapido y bien',
      type: MissionType.epica,
      xp: 8,
      gold: 40,
      icon: '\u{23F0}'),
  Mission(
      id: 20,
      name: 'La Defensora de la Paz Familiar',
      description: 'Pasar todo el dia sin rabietas ni conflictos',
      type: MissionType.epica,
      xp: 12,
      gold: 75,
      icon: '\u{1F54A}\u{FE0F}'),
];

/// Recompensas base del juego.
const List<Reward> kRewards = [
  // --- Pequenas ---
  Reward(id: 1, name: 'Elegir el Postre del Dia', description: 'Tu eliges que postre comer hoy', price: 40, category: RewardCategory.pequena, icon: '\u{1F366}'),
  Reward(id: 2, name: 'Elegir Dibujos Hoy', description: 'Tu decides que ver en la tele', price: 45, category: RewardCategory.pequena, icon: '\u{1F4FA}'),
  Reward(id: 3, name: 'Elegir la Cancion del Coche', description: 'Poner tu musica favorita en el coche', price: 40, category: RewardCategory.pequena, icon: '\u{1F3B5}'),
  Reward(id: 4, name: 'Tiempo Extra de Pintar', description: '15 minutos extra para dibujar o pintar', price: 55, category: RewardCategory.pequena, icon: '\u{1F3A8}'),
  Reward(id: 5, name: 'Elegir el Cuento', description: 'Tu eliges que cuento leer antes de dormir', price: 45, category: RewardCategory.pequena, icon: '\u{1F4D6}'),
  Reward(id: 6, name: 'Dormir con un Peluche Extra', description: 'Esta noche puedes llevar un peluche mas a la cama', price: 60, category: RewardCategory.pequena, icon: '\u{1F9F8}'),
  Reward(id: 24, name: 'Chucheria o Chocolatina', description: 'Una golosina especial para disfrutar', price: 35, category: RewardCategory.pequena, icon: '\u{1F36C}', cooldownHours: 48),

  // --- Medias ---
  Reward(id: 7, name: 'Cine en Casa', description: 'Ver una pelicula especial en familia', price: 200, category: RewardCategory.media, icon: '\u{1F3AC}'),
  Reward(id: 8, name: 'Palomitas Especiales', description: 'Hacer palomitas y comerlas viendo algo juntos', price: 150, category: RewardCategory.media, icon: '\u{1F37F}'),
  Reward(id: 9, name: 'Juego de Mesa en Familia', description: 'Jugar al juego de mesa que tu elijas', price: 180, category: RewardCategory.media, icon: '\u{1F3B2}'),
  Reward(id: 10, name: 'Bano con Espuma Extra', description: 'Un bano especial con muchas burbujas y juguetes', price: 160, category: RewardCategory.media, icon: '\u{1F6C1}'),
  Reward(id: 11, name: '30 Minutos Extra de Juego', description: 'Media hora mas para jugar a lo que quieras', price: 200, category: RewardCategory.media, icon: '\u{1F3AE}'),
  Reward(id: 12, name: 'Hacer Galletas Juntos', description: 'Cocinar galletas especiales en familia', price: 220, category: RewardCategory.media, icon: '\u{1F36A}'),

  // --- Grandes ---
  Reward(id: 13, name: 'Dia de Capricho', description: 'Un dia donde tu decides muchas cosas', price: 350, category: RewardCategory.grande, icon: '\u{1F389}'),
  Reward(id: 14, name: 'Elegir Merienda Especial', description: 'Preparar una merienda que tu elijas', price: 300, category: RewardCategory.grande, icon: '\u{1F9C1}'),
  Reward(id: 15, name: 'Sorpresa Misteriosa', description: 'Una sorpresa que te va a encantar', price: 400, category: RewardCategory.grande, icon: '\u{1F381}'),
  Reward(id: 16, name: 'Elegir Actividad del Fin de Semana', description: 'Tu decides que hacer el sabado o domingo', price: 380, category: RewardCategory.grande, icon: '\u{1F3F0}'),
  Reward(id: 17, name: 'Elegir Algo Pequeno en la Tienda', description: 'Comprar un juguete o cosa pequena que te guste', price: 400, category: RewardCategory.grande, icon: '\u{1F6CD}\u{FE0F}'),
  Reward(id: 18, name: 'Fiesta en Casa', description: 'Hacer una mini fiesta con musica, baile y decoracion', price: 350, category: RewardCategory.grande, icon: '\u{1F388}'),

  // --- Epicas ---
  Reward(id: 19, name: 'Dia de la Reina del Hogar', description: 'Un dia entero especial donde eres la protagonista', price: 500, category: RewardCategory.epica, icon: '\u{1F451}'),
  Reward(id: 20, name: 'Evento Legendario Familiar', description: 'Una excursion o plan super especial en familia', price: 600, category: RewardCategory.epica, icon: '\u{1F31F}'),

  // --- Pociones ---
  Reward(id: 21, name: 'Pocion de Vida Menor', description: 'Restaura 1 corazon de vida', price: 100, category: RewardCategory.potion, icon: '\u{1F9EA}', effect: PotionEffect.restoreLife, value: 1),
  Reward(id: 22, name: 'Super Pocion', description: 'Restaura 2 corazones de vida', price: 200, category: RewardCategory.potion, icon: '\u{2697}\u{FE0F}', effect: PotionEffect.restoreLife, value: 2),
  Reward(id: 23, name: 'Pocion de Energia', description: 'Restaura 2 puntos de energia', price: 120, category: RewardCategory.potion, icon: '\u{26A1}', effect: PotionEffect.restoreEnergy, value: 2),
];

/// Iconos disponibles para misiones y recompensas personalizadas.
const List<String> kAvailableIcons = [
  '\u{1F3E0}', '\u{1F9F9}', '\u{1F9FC}', '\u{1F9F4}', '\u{1F37D}\u{FE0F}',
  '\u{1F373}', '\u{1F6BF}', '\u{1F6CF}\u{FE0F}', '\u{1F455}', '\u{1F45F}',
  '\u{1F4DA}', '\u{270D}\u{FE0F}', '\u{1F3A8}', '\u{1F3B5}', '\u{26BD}',
  '\u{1F6B2}', '\u{1F3AE}', '\u{1F9E9}', '\u{2728}', '\u{1F31F}',
  '\u{1F4AA}', '\u{2764}\u{FE0F}', '\u{1F60A}', '\u{1F389}', '\u{1F381}',
  '\u{1F3C6}', '\u{1F451}', '\u{1F48E}', '\u{1F525}', '\u{26A1}',
];
