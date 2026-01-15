# ✅ Lista de Verificación - Heroína del Hogar

## 🔧 Verificación Inicial

- [ ] Python 3 instalado: `python3 --version`
- [ ] Todos los archivos presentes (ver estructura abajo)
- [ ] Permisos de ejecución: `chmod +x server.py iniciar.sh`

## 📁 Estructura de Archivos

```
/home/david/Escritorio/Rol/
├── index.html ✓
├── misiones.html ✓
├── tienda.html ✓
├── server.py ✓
├── iniciar.sh ✓
├── README.md ✓
├── INSTRUCCIONES_RAPIDAS.txt ✓
├── css/
│   └── styles.css ✓
├── js/
│   ├── data.js ✓
│   ├── game.js ✓
│   └── storage.js ✓
└── img/
    └── .gitkeep ✓
```

## 🧪 Pruebas de Funcionalidad

### 1. Iniciar Servidor
- [ ] Ejecutar: `python3 server.py` o `./iniciar.sh`
- [ ] El servidor inicia sin errores
- [ ] Se muestra la IP local
- [ ] Se muestra el puerto (8000)

### 2. Acceso Local (PC)
- [ ] Abrir navegador en: `http://localhost:8000`
- [ ] La página principal carga correctamente
- [ ] Se ve el diseño con colores de aventura
- [ ] No hay errores en la consola del navegador (F12)

### 3. Página Principal (index.html)
- [ ] Se muestra el nombre del personaje
- [ ] Se muestra el nivel (1 por defecto)
- [ ] Se muestra la barra de XP
- [ ] Se muestra el oro (0 por defecto)
- [ ] Se muestran los corazones de energía
- [ ] Se muestra el título "Aprendiz del Orden"
- [ ] Estadísticas de hoy en 0
- [ ] Botones "Ver Misiones" y "Ir a la Tienda" funcionan

### 4. Cambiar Nombre del Personaje
- [ ] Hacer clic en el botón del lápiz junto al nombre
- [ ] Aparece prompt para cambiar nombre
- [ ] Escribir nuevo nombre y aceptar
- [ ] El nombre se actualiza en la página
- [ ] Recargar página: el nombre persiste (localStorage)

### 5. Subir Avatar
- [ ] Hacer clic en "Cambiar Foto"
- [ ] Seleccionar una imagen
- [ ] La imagen se muestra en el avatar
- [ ] Recargar página: el avatar persiste

### 6. Página de Misiones (misiones.html)
- [ ] Navegar a Misiones desde el menú
- [ ] Se muestran 20 misiones en total
- [ ] Misiones organizadas por tipo (Diarias, Ayuda, Épicas)
- [ ] Cada misión muestra: icono, nombre, descripción, XP, Oro
- [ ] Filtros funcionan (Todas, Diarias, Ayuda, Épicas)
- [ ] Header muestra: Nivel, Oro, Misiones Hoy

### 7. Completar Misión
- [ ] Hacer clic en "Completar" en una misión
- [ ] Aparece modal de confirmación
- [ ] Confirmar la misión
- [ ] Aparece modal de recompensa con confeti
- [ ] Se muestra XP ganada y Oro ganado
- [ ] El oro se actualiza en el header
- [ ] Recargar página: los valores persisten

### 8. Subida de Nivel
- [ ] Completar suficientes misiones para acumular 10 XP
- [ ] Al llegar a 10 XP, aparece modal de subida de nivel
- [ ] Se muestra "¡Subiste de Nivel!"
- [ ] Se muestra el nuevo nivel (2)
- [ ] Se muestra el nuevo título
- [ ] La barra de XP se resetea a 0
- [ ] Confeti dorado más intenso

### 9. Página de Tienda (tienda.html)
- [ ] Navegar a Tienda desde el menú
- [ ] Se muestran 20 recompensas en total
- [ ] Recompensas organizadas por categoría
- [ ] Cada recompensa muestra: icono, nombre, descripción, precio
- [ ] Recompensas bloqueadas muestran nivel requerido
- [ ] Filtros funcionan (Todas, Pequeñas, Medias, Grandes, Épicas)
- [ ] Header muestra: Nivel, Oro, Compradas

### 10. Comprar Recompensa
- [ ] Tener suficiente oro (completar misiones primero)
- [ ] Hacer clic en "Comprar" en una recompensa disponible
- [ ] Aparece modal de confirmación con precio
- [ ] Confirmar compra
- [ ] Aparece modal de éxito con confeti
- [ ] El oro se descuenta
- [ ] El contador de "Compradas" aumenta
- [ ] Recargar página: los valores persisten

### 11. Recompensas Bloqueadas
- [ ] Intentar ver recompensas épicas en nivel bajo
- [ ] Las recompensas muestran candado y nivel requerido
- [ ] No se pueden comprar hasta alcanzar el nivel
- [ ] Están atenuadas visualmente

### 12. Navegación Entre Páginas
- [ ] Navegar entre todas las páginas usando el menú
- [ ] El estado se mantiene entre páginas
- [ ] No se pierden datos al cambiar de página
- [ ] Los estilos se cargan correctamente en todas

### 13. Responsive Design
- [ ] Reducir el tamaño de la ventana del navegador
- [ ] El diseño se adapta a móvil
- [ ] El menú se convierte en hamburguesa
- [ ] Las tarjetas se apilan verticalmente
- [ ] Todo es legible y usable en pantalla pequeña

### 14. Animaciones y Efectos
- [ ] Confeti al completar misiones
- [ ] Confeti dorado al subir de nivel
- [ ] Confeti al comprar recompensas
- [ ] Iconos flotan suavemente
- [ ] Botones tienen efecto hover
- [ ] Cards tienen efecto hover (elevan)
- [ ] Barra de XP animada

### 15. Persistencia de Datos
- [ ] Completar algunas misiones
- [ ] Comprar alguna recompensa
- [ ] Subir de nivel
- [ ] Cerrar el navegador completamente
- [ ] Abrir de nuevo: `http://localhost:8000`
- [ ] Todos los datos persisten (nivel, XP, oro, nombre, avatar)

### 16. Estadísticas
- [ ] Completar misiones en el día actual
- [ ] Ver que "Misiones Hoy" aumenta
- [ ] Ver que "XP Ganada" y "Oro Ganado" aumentan
- [ ] La racha se calcula correctamente

### 17. Reiniciar Progreso
- [ ] Ir a la página principal
- [ ] Hacer scroll hasta abajo
- [ ] Hacer clic en "Reiniciar Progreso"
- [ ] Confirmar la acción
- [ ] Todos los datos vuelven a valores iniciales
- [ ] Nivel 1, XP 0, Oro 0, etc.

### 18. Acceso desde Móvil (Red Local)
- [ ] El servidor está corriendo en el PC
- [ ] Anotar la IP mostrada (ej: 192.168.1.100:8000)
- [ ] En móvil/tablet, conectar a la misma WiFi
- [ ] Abrir navegador en móvil
- [ ] Escribir la dirección IP
- [ ] La aplicación carga correctamente
- [ ] Todas las funcionalidades funcionan igual

### 19. Múltiples Dispositivos
- [ ] Abrir en PC: `http://localhost:8000`
- [ ] Abrir en Móvil: `http://IP:8000`
- [ ] Cada dispositivo tiene su propia copia de datos
- [ ] Los cambios en un dispositivo no afectan al otro
- [ ] (Esto es por diseño - localStorage es local)

### 20. Consola del Navegador
- [ ] Abrir DevTools (F12)
- [ ] Ir a la pestaña "Console"
- [ ] No debe haber errores en rojo
- [ ] Solo logs informativos si los hay

## 🎨 Verificación Visual

### Colores y Tema Aventura
- [ ] Navbar: verde oscuro con degradado
- [ ] Fondo: degradado verde claro
- [ ] Cards: blanco con sombras
- [ ] Botones: colores vibrantes con degradados
- [ ] Badges: dorados para títulos, coloreados para recompensas
- [ ] Misiones: bordes verdes (diarias), azules (ayuda), amarillos (épicas)

### Tipografía
- [ ] Títulos: MedievalSharp (fuente fantasy)
- [ ] Texto normal: Quicksand (legible y moderna)
- [ ] Tamaños adecuados en móvil y desktop

### Iconos
- [ ] Emojis grandes y claros para misiones
- [ ] Emojis grandes y claros para recompensas
- [ ] Bootstrap Icons en navegación y botones
- [ ] Todo se ve bien en diferentes navegadores

## 🐛 Errores Comunes a Verificar

- [ ] No hay enlaces rotos
- [ ] No hay imágenes rotas (excepto avatar si no se sube)
- [ ] No hay scripts que no carguen (verificar red en DevTools)
- [ ] localStorage funciona (no en modo incógnito)
- [ ] Los modales se abren y cierran correctamente
- [ ] Los filtros funcionan sin errores

## 📊 Datos de Prueba Sugeridos

1. **Primera Sesión**:
   - Cambiar nombre a "Luna" o el nombre de la niña
   - Subir una foto de avatar
   - Completar 3-4 misiones diarias
   - Subir al nivel 2
   - Ver el nuevo título

2. **Segunda Sesión**:
   - Completar misiones de ayuda
   - Acumular ~100 oro
   - Comprar una recompensa pequeña
   - Verificar que el oro se descuenta

3. **Tercera Sesión**:
   - Completar misiones épicas
   - Subir varios niveles
   - Comprar recompensas más caras
   - Ver recompensas desbloqueadas

## ✅ Checklist Final

- [ ] Todos los archivos HTML cargan sin errores
- [ ] Todos los scripts JS funcionan correctamente
- [ ] Los estilos CSS se aplican correctamente
- [ ] El servidor Python funciona en red local
- [ ] La aplicación es usable desde móvil
- [ ] Los datos persisten correctamente
- [ ] Las animaciones funcionan
- [ ] El diseño es responsive
- [ ] No hay errores en consola
- [ ] La experiencia es fluida y divertida

## 🎉 ¡Proyecto Completado!

Si todas las pruebas pasan, ¡la aplicación está lista para usar!

**Próximos pasos:**
1. Personalizar las misiones según las tareas de tu hogar
2. Ajustar las recompensas a lo que le guste a la niña
3. Configurar el nombre y avatar del personaje
4. ¡Empezar a gamificar las tareas del día a día!

---

**Fecha de prueba:** _______________

**Probado por:** _______________

**Estado:** ⬜ Todo OK  ⬜ Necesita ajustes

**Notas:**
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
