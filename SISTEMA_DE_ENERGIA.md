# ❤️ Sistema de Energía - Heroína del Hogar

## 🎮 Cómo Funciona

### Energía Base
- **Energía máxima:** 6 corazones ❤️❤️❤️❤️❤️❤️
- **Costo por misión:** 2 corazones ❤️❤️
- **Misiones posibles al día:** 3 misiones (6 ÷ 2 = 3)

---

## 🔄 Recuperación de Energía

### 1️⃣ Recuperación Diaria (Automática)
- **Cuándo:** Cada día a las 00:00 (medianoche)
- **Cantidad:** Energía completa (6 ❤️)
- **Cómo:** Automático, solo abre la app al día siguiente

### 2️⃣ Bonus por Subir de Nivel
- **Cuándo:** Al subir de nivel
- **Cantidad:** +2 corazones ❤️❤️
- **Máximo:** No supera 6 corazones
- **Ejemplo:** 
  - Tienes 2 ❤️
  - Subes de nivel
  - Ahora tienes 4 ❤️

---

## 🚫 Restricciones

### No Puedes Iniciar Misiones Si:
- Tienes **menos de 2 corazones** ❤️
- Ya hay una misión en progreso
- Mensaje: *"No tienes suficiente energía (necesitas 2 ❤️)"*

### Puedes Hacerlo:
- ✅ Cancelar una misión en curso (no consume energía)
- ✅ Ver la tienda y comprar recompensas
- ✅ Ver tus estadísticas
- ✅ Esperar al día siguiente para recuperar energía

---

## 📊 Ejemplos de Uso

### Escenario 1: Día Normal
```
Inicio del día:
  Energía: ❤️❤️❤️❤️❤️❤️ (6/6)

Hace misión 1:
  Energía: ❤️❤️❤️❤️🤍🤍 (4/6)

Hace misión 2:
  Energía: ❤️❤️🤍🤍🤍🤍 (2/6)

Hace misión 3:
  Energía: 🤍🤍🤍🤍🤍🤍 (0/6)
  → No puede hacer más misiones hoy

Al día siguiente:
  Energía: ❤️❤️❤️❤️❤️❤️ (6/6)
  → ¡Todo recuperado!
```

### Escenario 2: Con Subida de Nivel
```
Energía actual: ❤️❤️🤍🤍🤍🤍 (2/6)

Completa misión épica:
  - Gana mucha XP
  - ¡Sube de nivel!
  - Bonus: +2 ❤️

Energía nueva: ❤️❤️❤️❤️🤍🤍 (4/6)

→ ¡Puede hacer 2 misiones más!
```

### Escenario 3: Sin Energía
```
Energía: 🤍🤍🤍🤍🤍🤍 (0/6)

Intenta iniciar misión:
  ❌ Botón deshabilitado
  Mensaje: "Sin energía (necesitas 2 ❤️)"

Opciones:
  1. Esperar al día siguiente
  2. Subir de nivel (+2 ❤️ bonus)
  3. Hacer otras cosas (ver stats, comprar recompensas)
```

---

## 🎯 Ventajas del Sistema

✅ **Límite saludable:** Máximo 3 tareas al día
✅ **No frustrante:** Puede hacer 3 misiones completas
✅ **Estratégico:** Decide qué misiones hacer
✅ **Motivador:** Subir de nivel recupera energía
✅ **Simple:** Fácil de entender para niños
✅ **Visual:** Los corazones muestran claramente el estado

---

## 💡 Consejos de Uso

### Para Padres:
1. **Explica el sistema:** "Tienes 3 tareas que puedes hacer hoy"
2. **Deja que elija:** "¿Qué 3 misiones quieres hacer?"
3. **Celebra el límite:** "¡Muy bien! Ya hiciste tus 3 tareas de hoy"
4. **No lo veas como castigo:** Es un límite sano de responsabilidades

### Para la Niña:
1. **Prioriza:** Elige las misiones que más te gusten
2. **Distribuye:** No hagas las 3 seguidas si no quieres
3. **Aprovecha los bonus:** Cuando subes de nivel, ¡ganas más energía!
4. **Mañana es otro día:** Si te quedas sin energía, mañana vuelves a tener

---

## 🔍 Dónde Ver la Energía

### Pantalla Principal (index.html)
```
┌─────────────────┐
│  Energía        │
│  ❤️❤️❤️🤍🤍🤍  │
│  Cada misión    │
│  cuesta 2 ❤️    │
└─────────────────┘
```

### Página de Misiones (misiones.html)
**Header superior:**
```
Nivel: 5  |  Energía: 4/6 ❤️  |  Oro: 250  |  Hoy: 2
```

**En cada tarjeta de misión:**
```
┌──────────────────────┐
│   Misión Diaria      │
│                      │
│  ❤️ 2 Energía       │  ← Costo visible
│  ⭐ 3 XP            │
│  💰 15 Oro          │
│                      │
│ Iniciar Misión (-2❤️)│ ← Recordatorio
└──────────────────────┘
```

**Cuando no hay energía:**
```
┌──────────────────────┐
│   Misión (Gris)      │
│                      │
│  Sin energía         │  ← Bloqueada
│  (necesitas 2 ❤️)    │
└──────────────────────┘
```

---

## 🎨 Elementos Visuales

### Corazones Llenos
- Emoji: ❤️
- Color: Rojo brillante
- Animación: Latido suave (pulse)

### Corazones Vacíos
- Emoji: 🤍
- Color: Blanco/gris
- Opacidad: 50%

### Estados de Energía

**Alta (5-6 ❤️):**
```
❤️❤️❤️❤️❤️❤️  → ¡Perfecta para misiones!
```

**Media (3-4 ❤️):**
```
❤️❤️❤️❤️🤍🤍  → Puede hacer 2 misiones
```

**Baja (1-2 ❤️):**
```
❤️❤️🤍🤍🤍🤍  → Solo 1 misión disponible
```

**Vacía (0 ❤️):**
```
🤍🤍🤍🤍🤍🤍  → Sin misiones hasta mañana
```

---

## 🔧 Detalles Técnicos

### Archivos Modificados
1. **js/storage.js**
   - Campo `energiaMaxima: 6`
   - Recuperación diaria automática
   - Bonus +2 al subir nivel
   - Consume 2 al completar misión

2. **js/game.js**
   - Verificación de energía antes de iniciar
   - Mensaje de error si no hay suficiente

3. **index.html**
   - Mostrar corazones dinámicamente
   - Texto explicativo del costo

4. **misiones.html**
   - Badge rojo "2 Energía" en cada misión
   - Header con energía actual
   - Bloqueo visual si no hay energía
   - Botones muestran "-2 ❤️"

5. **css/styles.css**
   - Clase `.corazon-lleno` (con animación)
   - Clase `.corazon-vacio` (atenuado)

---

## 📈 Balance del Sistema

### Cálculo Diario
```
Energía disponible:  6 ❤️
Costo por misión:    2 ❤️
────────────────────────
Misiones posibles:   3 misiones/día

Con bonus de nivel:
Energía extra:       +2 ❤️
────────────────────────
Misiones extra:      +1 misión
Total ese día:       4 misiones
```

### Comparación

| Sistema | Misiones/Día | Apropiado para 6 años |
|---------|--------------|----------------------|
| Sin límite | ∞ | ❌ Demasiado |
| 1 energía/misión (6 max) | 6 | ⚠️ Quizás mucho |
| **2 energía/misión (6 max)** | **3** | ✅ **Perfecto** |
| 3 energía/misión (6 max) | 2 | ⚠️ Quizás poco |

---

## 🆕 Futuras Mejoras (Opcionales)

Si quieres añadir más adelante:

### Recompensa en la Tienda
```javascript
{
    nombre: "Poción de Energía",
    descripcion: "Recupera 2 corazones de energía",
    precio: 100,
    icono: "⚡",
    efecto: "+2 energía"
}
```

### Recuperación por Horas
```javascript
// +1 energía cada 4 horas
// Máximo 6 corazones
// Así puede hacer misiones a lo largo del día
```

### Energía Bonus en Fines de Semana
```javascript
// Sábado y Domingo: 8 corazones
// Puede hacer 4 misiones
```

---

## ❓ Preguntas Frecuentes

**P: ¿Qué pasa si cancelo una misión?**
R: No pasa nada, recuperas el tiempo pero la energía NO se devuelve.

**P: ¿Puedo comprar energía con oro?**
R: No por ahora, pero se puede añadir como recompensa.

**P: ¿Se recupera mientras duerme?**
R: Se recupera al cambiar de día (00:00), no importa si duerme o no.

**P: ¿Qué pasa con los datos antiguos?**
R: Se actualizan automáticamente a 6 corazones la primera vez.

**P: ¿Puedo cambiar de 6 a otro número?**
R: Sí, edita `energiaMaxima: 6` en `js/storage.js`

**P: ¿Por qué 2 de costo y no 1?**
R: Para limitar a 3 misiones/día, un número razonable para una niña de 6 años.

---

## ✅ Resumen

- 🎯 **6 corazones** máximos
- ⚡ **2 corazones** por misión
- 📅 **3 misiones** posibles al día
- 🔄 **Recuperación** automática cada día
- 🎁 **Bonus** de +2 al subir nivel
- 🚫 **Bloqueo** claro cuando no hay energía
- 👁️ **Visual** simple y comprensible

¡Sistema implementado y listo para usar! 🎮✨
