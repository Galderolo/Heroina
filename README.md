# 🏰 Heroína del Hogar - Sistema de Gamificación

Un sistema de gamificación diseñado para motivar a niños pequeños a través de misiones, niveles y recompensas.

## 📋 Características

- **Sistema de Niveles**: Sube de nivel completando misiones
- **20 Misiones Narrativas**: Tareas del hogar convertidas en aventuras épicas
- **20 Títulos Desbloqueables**: Cada nivel otorga un nuevo título
- **20 Recompensas**: Desde pequeñas hasta épicas
- **Sistema de Oro**: Gana oro completando misiones, gástalo en recompensas
- **Persistencia Local**: Los datos se guardan en el navegador
- **Acceso en Red Local**: Úsalo desde cualquier dispositivo en tu WiFi
- **Animaciones y Celebraciones**: Confeti y efectos visuales al lograr objetivos

## 🚀 Inicio Rápido

### 1. Iniciar el Servidor

```bash
cd /home/david/Escritorio/Rol
python3 server.py
```

### 2. Acceder a la Aplicación

**Desde el mismo ordenador:**
- Abre tu navegador y ve a: `http://localhost:8000`

**Desde móvil/tablet (en la misma red WiFi):**
- El servidor mostrará una IP, por ejemplo: `http://192.168.1.100:8000`
- Escribe esa dirección en el navegador de tu móvil

## 📱 Uso

### Primera Vez
1. Abre la aplicación
2. Configura el nombre del personaje
3. (Opcional) Sube una foto para el avatar
4. ¡Listo para empezar!

### Completar Misiones
1. Ve a la sección **Misiones**
2. Cuando la niña complete una tarea, marca la misión como completada
3. Verás animaciones de recompensa con la XP y Oro ganados
4. Si sube de nivel, recibirá un nuevo título

### Comprar Recompensas
1. Ve a la **Tienda**
2. Usa el oro ganado para comprar recompensas
3. Las recompensas se desbloquean según el nivel del personaje

## 🎮 Sistema de Progresión

### Niveles y XP
- **Nivel 1→2**: 10 XP
- **Nivel 2→3**: 15 XP
- **Nivel 3→4**: 20 XP
- **Progresión**: +5 XP por cada nivel

### Tipos de Misiones
- 🟢 **Diarias** (2-3 XP, 10-15 Oro): Tareas cotidianas
- 🔵 **Ayuda** (4-5 XP, 20-30 Oro): Ayudar en casa
- 🟣 **Épicas** (8-15 XP, 40-80 Oro): Grandes logros

### Categorías de Recompensas
- 🟢 **Pequeñas** (50-100 Oro): Placeres simples
- 🔵 **Medias** (150-250 Oro): Actividades especiales
- 🟡 **Grandes** (300-400 Oro): Eventos importantes
- 🔴 **Épicas** (500+ Oro): Recompensas legendarias

## 📂 Estructura del Proyecto

```
/home/david/Escritorio/Rol/
├── index.html          # Página principal - Hoja de personaje
├── misiones.html       # Lista de misiones
├── tienda.html         # Tienda de recompensas
├── server.py           # Servidor HTTP para red local
├── README.md           # Este archivo
├── css/
│   └── styles.css      # Estilos personalizados
├── js/
│   ├── data.js         # Datos: misiones, títulos, recompensas
│   ├── game.js         # Lógica del juego
│   └── storage.js      # Persistencia con localStorage
└── img/
    └── avatar.jpg      # Foto del avatar (configurable)
```

## 🎨 Diseño

- **Temática**: Aventura con colores tierra, verdes y dorados
- **Tipografía**: MedievalSharp (títulos) + Quicksand (texto)
- **Responsive**: Funciona perfectamente en móvil, tablet y desktop
- **Animaciones**: Confeti, brillos, flotación de iconos

## 💾 Datos y Persistencia

Los datos se guardan automáticamente en el **localStorage** del navegador:
- Nombre del personaje
- Nivel y XP actual
- Oro total
- Historial de misiones completadas
- Recompensas compradas
- Avatar personalizado

**Importante**: 
- Los datos persisten incluso si cierras el navegador
- Si usas diferentes dispositivos, cada uno tendrá su propia copia
- Se recomienda usar un dispositivo principal (tablet familiar)

## 🔧 Requisitos

- Python 3.x (para el servidor)
- Navegador web moderno (Chrome, Firefox, Safari, Edge)
- Red WiFi local (para acceso desde móviles)

## 🎯 Misiones Disponibles

### Misiones Diarias
1. Preparar el Campamento del Descanso (hacer la cama)
2. Salvar a los Juguetes Perdidos (recoger juguetes)
3. El Ritual del Cepillo Valiente (lavarse los dientes)
4. El Hechizo del Agua Brillante (lavarse manos y cara)
5. Ordenar la Base Secreta (recoger el cuarto)
6. Despertar con Energía de Heroína (vestirse sola)
7. Cerrar el Portal del Desorden (recoger lo usado)

### Misiones de Ayuda
8. Ayudar al Gran Chef del Reino (ayudar a cocinar)
9. La Misión del Lavavajillas Mágico (sacar/meter lavavajillas)
10. Transportar los Tesoros del Súper (meter compras)
11. Doblar las Telas Encantadas (doblar ropa)
12. El Guardián del Cubo de la Basura (tirar basura)
13. Organizar el Altar de los Zapatos (colocar zapatos)

### Misiones Épicas
14. La Gran Limpieza del Reino (recoger cuarto entero)
15. El Baño de las Burbujas Legendarias (ducharse sin protestar)
16. Ayuda Extra al Consejo Familiar (ayudar sin que lo pidan)
17. El Día del Buen Comportamiento (cumplir normas todo el día)
18. Misión de la Sonrisa Valiente (hacer algo difícil sin enfadarse)
19. El Reto del Tiempo Mágico (hacer tarea rápido y bien)
20. La Jornada de la Heroína Completa (5 misiones en un día)

## 🏆 Títulos Desbloqueables

1. Aprendiz del Orden
2. Guardiana de la Cama Sagrada
3. Exploradora del Cuarto Perdido
4. Amiga de los Cepillos Valientes
5. Heroína del Agua Brillante
6. Ayudante del Gran Chef
7. Protectora de los Juguetes
8. Señora del Cajón Misterioso
9. Maestra de las Manos Limpias
10. Vigilante del Reino Doméstico
11. Arquitecta del Hogar Feliz
12. Portadora de la Toalla Legendaria
13. Defensora del Orden Secreto
14. Campeona del Buen Hábito
15. Dama de la Cocina Encantada
16. Custodia del Baño Reluciente
17. Guardián de las Cosas del Súper
18. Heroína del Día Completado
19. Maestra del Hogar Mágico
20. Gran Guardiana del Reino del Orden

## 🎁 Recompensas de la Tienda

### Pequeñas
- Elegir el Postre del Día
- Elegir Dibujos Hoy
- Elegir la Canción del Coche
- Tiempo Extra de Pintar
- Elegir el Cuento
- Dormir con un Peluche Extra

### Medias
- Cine en Casa
- Palomitas Especiales
- Juego de Mesa en Familia
- Baño con Espuma Extra
- 30 Minutos Extra de Juego
- Hacer Galletas Juntos

### Grandes
- Día de Capricho
- Elegir Merienda Especial
- Sorpresa Misteriosa
- Elegir Actividad del Fin de Semana
- Elegir Algo Pequeño en la Tienda
- Fiesta en Casa

### Épicas
- Día de la Reina del Hogar
- Evento Legendario Familiar

## ⚙️ Personalización

Puedes personalizar fácilmente:
- **Misiones**: Edita `js/data.js` - array `MISIONES`
- **Títulos**: Edita `js/data.js` - array `TITULOS`
- **Recompensas**: Edita `js/data.js` - array `RECOMPENSAS`
- **Colores**: Edita `css/styles.css` - variables CSS en `:root`
- **XP por nivel**: Edita la función `calcularXPParaNivel()` en `js/data.js`

## 🔄 Reiniciar Progreso

Para borrar todo el progreso y empezar de nuevo:
1. Ve a la página principal
2. Pulsa el botón "Reiniciar Progreso" (abajo de todo)
3. Confirma la acción

**⚠️ Advertencia**: Esta acción NO se puede deshacer.

## 🐛 Solución de Problemas

### No puedo acceder desde el móvil
- Verifica que ambos dispositivos estén en la misma red WiFi
- Comprueba que no haya firewall bloqueando el puerto 8000
- Intenta desactivar temporalmente el firewall del PC

### Los datos no se guardan
- Asegúrate de que las cookies/localStorage estén habilitadas
- No uses modo incógnito/privado
- Verifica que el navegador sea reciente

### El servidor no inicia
- Verifica que Python 3 esté instalado: `python3 --version`
- Comprueba que el puerto 8000 no esté ocupado
- Intenta cambiar el puerto en `server.py`

## 📝 Notas

- **Sin castigos**: El sistema está diseñado solo con refuerzo positivo
- **Predecible**: La niña siempre sabe qué ganará con cada misión
- **Visual**: Números grandes, iconos claros, mucho feedback
- **Celebración constante**: Cada logro se celebra con animaciones

## 🤝 Contribuir

Este es un proyecto personal, pero si quieres adaptarlo:
1. Copia todos los archivos
2. Personaliza misiones y recompensas según tu familia
3. Ajusta los valores de XP y Oro según la edad
4. ¡Diviértete!

## 📄 Licencia

Proyecto personal - Uso libre

---

**Hecho con ❤️ para motivar y celebrar los pequeños logros del día a día**
