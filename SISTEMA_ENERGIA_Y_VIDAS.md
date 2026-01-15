# ⚡❤️ Sistema de Energía y Vidas - Heroína del Hogar

## 🎮 Nuevo Sistema Dual

### ⚡ Energía (Límite de Misiones)
- **Función:** Controla cuántas misiones puedes hacer
- **Máximo:** 6 puntos de energía
- **Costo:** 2 energía por misión (iniciada)
- **Recuperación:** Automática cada día + bonus de nivel
- **Visual:** Número con rayo ⚡ (ej: `4/6 ⚡`)

### ❤️ Vidas (Consecuencia de Fracasos)
- **Función:** Se pierden al fracasar misiones
- **Máximo:** 3 corazones
- **Costo:** 1 vida por fracaso
- **Recuperación:** No automática (requiere recompensa o logro)
- **Visual:** Corazones rojos ❤️❤️❤️ o rotos 💔

---

## 🎯 Estados de una Misión

Ahora las misiones tienen **3 posibles resultados**:

### 1️⃣ **Completada** ✅
- **Cuándo:** La tarea se hizo correctamente
- **Consume:** 2 energía ⚡
- **Gana:** XP + Oro (recompensa completa)
- **Vidas:** No se pierden
- **Botón:** Verde "¡Completada!"

### 2️⃣ **Fracasada** ❌
- **Cuándo:** La tarea no se hizo o se hizo mal
- **Consume:** 2 energía ⚡ + 1 vida ❤️
- **Gana:** NADA (0 XP, 0 Oro)
- **Consecuencia:** Pierde 1 corazón
- **Botón:** Rojo "Fracasó (-1 ❤️)"

### 3️⃣ **Cancelada** 🔄
- **Cuándo:** Se cancela antes de terminar
- **Consume:** NADA
- **Gana:** NADA
- **Vidas:** No se pierden
- **Botón:** Gris "Cancelar"

---

## 📊 Flujo de Juego

### Escenario 1: Todo Sale Bien ✅
```
Estado inicial:
  Energía: 6/6 ⚡
  Vidas: ❤️❤️❤️

1. Inicia "Hacer la Cama"
   Energía: 6/6 ⚡ (no consume hasta completar)
   Vidas: ❤️❤️❤️

2. ¡Completada!
   Energía: 4/6 ⚡ (-2)
   Vidas: ❤️❤️❤️ (sin cambios)
   Gana: +3 XP, +15 Oro

3. Inicia "Lavarse Dientes"
   Energía: 4/6 ⚡
   Vidas: ❤️❤️❤️

4. ¡Completada!
   Energía: 2/6 ⚡ (-2)
   Vidas: ❤️❤️❤️
   Gana: +2 XP, +10 Oro

Resultado: ¡Perfecto!
```

### Escenario 2: Fracaso en Misión ❌
```
Estado inicial:
  Energía: 6/6 ⚡
  Vidas: ❤️❤️❤️

1. Inicia "Recoger Cuarto"
   Energía: 6/6 ⚡
   Vidas: ❤️❤️❤️

2. Fracasó (no lo hizo)
   Energía: 4/6 ⚡ (-2)
   Vidas: ❤️❤️💔 (-1 vida)
   Gana: NADA
   
⚠️ Mensaje: "Has perdido una vida. Vidas restantes: 2"

3. Inicia otra misión
   Energía: 4/6 ⚡
   Vidas: ❤️❤️💔

4. ¡Completada!
   Energía: 2/6 ⚡
   Vidas: ❤️❤️💔 (sin cambios)
   Gana: +3 XP, +15 Oro
```

### Escenario 3: Sin Vidas ⚠️
```
Estado:
  Energía: 4/6 ⚡
  Vidas: ❤️💔💔

1. Inicia misión
2. Fracasa

Resultado:
  Energía: 2/6 ⚡
  Vidas: 💔💔💔 (0 vidas)
  
⚠️ MENSAJE CRÍTICO:
"¡NO QUEDAN VIDAS! Ten más cuidado"

¿Qué pasa?
  - Puede seguir haciendo misiones
  - Pero NO puede permitirse más fracasos
  - Debe comprar "Recuperar Vida" en tienda
  - O esperar evento especial
```

### Escenario 4: Cancelar Misión 🔄
```
Estado:
  Energía: 6/6 ⚡
  Vidas: ❤️❤️❤️

1. Inicia "La Gran Limpieza"
   (Misión épica difícil)

2. Se da cuenta que es muy difícil
   Cancela la misión

Resultado:
  Energía: 6/6 ⚡ (sin cambios)
  Vidas: ❤️❤️❤️ (sin cambios)
  Gana: NADA
  
✅ Sin penalización, puede intentar otra
```

---

## 🔄 Recuperación

### ⚡ Energía
**Recuperación Automática:**
- ✅ Cada día (00:00): Energía completa (6/6)
- ✅ Al subir nivel: +2 energía (bonus)
- ✅ Máximo siempre: 6 energía

### ❤️ Vidas
**NO se recuperan automáticamente**

**Formas de recuperar:**
1. **Recompensa en Tienda** (futura):
   ```
   "Corazón Extra"
   Precio: 200 oro
   Efecto: +1 vida
   ```

2. **Al subir múltiples niveles**:
   - Cada 5 niveles: +1 vida
   - Nivel 5, 10, 15, 20...

3. **Evento especial**:
   - Completar X misiones perfectas seguidas
   - Día especial (cumpleaños, etc.)

---

## 🎨 Interfaz Visual

### Pantalla Principal
```
┌─────────────────────────────────────┐
│  Oro        Energía       Vidas     │
│  250        4/6 ⚡       ❤️❤️💔     │
│                                      │
│  Cada       Se pierden              │
│  misión     al fracasar             │
│  cuesta 2⚡                          │
└─────────────────────────────────────┘
```

### Misión Activa
```
┌─────────────────────────────────────┐
│  ⏳ Misión en Progreso              │
│                                      │
│         🛏️                          │
│  Preparar el Campamento             │
│  Iniciada hace 10 minutos           │
│                                      │
│  ┌──────────────────────────┐      │
│  │  ✅ ¡Completada!          │      │  ← Verde
│  └──────────────────────────┘      │
│                                      │
│  ┌──────────┐  ┌──────────┐        │
│  │ ❌ Fracasó│  │ 🔄 Cancelar│       │  ← Rojo / Gris
│  │ (-1 ❤️)   │  │           │       │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
```

### Tarjeta de Misión
```
┌──────────────────────┐
│  ⏳ En Progreso      │  ← Badge amarillo
│       🛏️             │
│ Hacer la Cama        │
│                      │
│ ⚡ 2 Energía         │  ← Azul
│ ⭐ 3 XP             │
│ 💰 15 Oro           │
│                      │
│ ✅ ¡Completada!      │  ← Verde grande
│                      │
│ ❌ Fracasó  🔄 Cancelar│ ← Rojo/Gris pequeños
│ (-1 ❤️)             │
└──────────────────────┘
```

### Header de Misiones
```
Nivel: 5  |  Energía: 4/6 ⚡  |  Vidas: ❤️❤️❤️  |  Oro: 250  |  Hoy: 2
```

---

## ⚖️ Balance del Sistema

### Energía vs Vidas

| Recurso | Recuperación | Penalización | Impacto |
|---------|--------------|--------------|---------|
| **Energía** ⚡ | Diaria automática | Limita misiones/día | Medio |
| **Vidas** ❤️ | Manual/difícil | Solo al fracasar | Alto |

### Estrategia Óptima
1. **Priorizar misiones fáciles** cuando tienes pocas vidas
2. **Guardar vidas** para misiones difíciles
3. **Cancelar si no estás seguro** (mejor que fracasar)
4. **No arriesgar** con 1 vida restante
5. **Comprar recuperación** cuando sea crítico

---

## 💡 Psicología del Sistema

### Por qué funciona:

**Energía (Límite diario):**
- ✅ Evita sobrecarga de tareas
- ✅ Recuperación predecible
- ✅ No es estresante

**Vidas (Consecuencia real):**
- ⚠️ Añade peso a las decisiones
- 🎯 Fomenta hacer las cosas bien
- 💪 Enseña responsabilidad
- 🧠 Estrategia: ¿intento esto o es muy difícil?

**Sistema Dual:**
- 🔄 Energía = límite técnico
- ❤️ Vidas = consecuencia moral
- 🎮 Más profundidad sin complejidad

---

## 🎯 Ventajas del Nuevo Sistema

### Antes (Solo Energía):
- Podías hacer 3 misiones
- No había diferencia entre completar o no
- Poca estrategia

### Ahora (Energía + Vidas):
- ⚡ Puedes hacer 3 misiones
- ❤️ Pero debes hacerlas BIEN
- 🧠 Decides qué intentar
- 💪 Consecuencias reales
- 🎮 Más interesante y educativo

---

## 📋 Ejemplos de Uso Educativo

### Niña Decide Cancelar (Buena decisión)
```
Situación:
  - Misión: "La Gran Limpieza del Reino"
  - La niña está cansada
  - Tiene solo 1 vida ❤️💔💔

Decisión:
  - "Esto es muy difícil ahora"
  - Cancela la misión
  - No pierde vida

Aprendizaje:
  ✅ Reconocer límites
  ✅ Tomar decisiones inteligentes
  ✅ No es fracasar, es ser estratégico
```

### Padre Marca Fracaso (Enseñanza)
```
Situación:
  - Misión: "Lavarse los Dientes"
  - La niña no lo hizo
  - Mintió diciendo que sí

Consecuencia:
  - Padre marca "Fracasó"
  - Pierde 1 vida ❤️ → 💔
  - Se muestra mensaje claro

Conversación:
  "Perdiste un corazón porque no hiciste la tarea.
   Las mentiras tienen consecuencias.
   ¿Qué haremos diferente mañana?"

Aprendizaje:
  ✅ Honestidad
  ✅ Responsabilidad
  ✅ Consecuencias visuales
```

---

## 🔧 Detalles Técnicos

### Archivos Modificados
1. **js/storage.js**
   - Campo `vidas: 3` y `vidasMaximas: 3`
   - Función `fracasarMisionActiva()`
   - Función `recuperarVida()`

2. **js/game.js**
   - Función `fracasarMisionActiva()`
   - Resultado incluye `tipo: 'completada'` o `'fracasada'`

3. **index.html**
   - 3 cards: Oro, Energía ⚡, Vidas ❤️
   - 3 botones: Completar, Fracasar, Cancelar
   - Función `fracasarMisionActiva()`

4. **misiones.html**
   - Header con vidas
   - 3 botones en cada misión activa
   - Badge azul para energía ⚡

---

## ❓ Preguntas Frecuentes

**P: ¿Qué pasa si me quedo sin vidas?**
R: Puedes seguir jugando, pero no puedes permitirte más fracasos. Debes comprar "Recuperar Vida" o subir niveles.

**P: ¿Se recuperan las vidas al día siguiente?**
R: NO. Las vidas no se recuperan automáticamente, son más valiosas que la energía.

**P: ¿Pierdo energía si cancelo?**
R: NO. Cancelar no tiene penalización, solo no ganas nada.

**P: ¿Pierdo energía si fracaso?**
R: SÍ. Fracasar consume energía (intentaste la misión) Y una vida.

**P: ¿Cuándo marco "Fracasó"?**
R: Cuando la tarea no se hizo o se hizo muy mal. Úsalo como consecuencia educativa.

**P: ¿Puedo recuperar vidas?**
R: Sí, mediante recompensas en la tienda (futura) o al subir múltiples niveles.

**P: ¿Qué es mejor, cancelar o arriesgar?**
R: Depende. Si tienes muchas vidas, arriesga. Si tienes pocas, mejor cancela.

---

## 🎁 Futura Recompensa: Recuperar Vida

```javascript
{
    nombre: "Corazón de Cristal",
    descripcion: "Recupera 1 vida perdida",
    precio: 200,
    categoria: "media",
    icono: "💎",
    nivelRequerido: 5,
    efecto: "+1 vida"
}
```

---

## ✅ Resumen del Sistema

| Aspecto | Energía ⚡ | Vidas ❤️ |
|---------|-----------|----------|
| **Máximo** | 6 | 3 |
| **Costo/Misión** | 2 (siempre) | 1 (solo si fracasa) |
| **Recuperación** | Diaria automática | Manual/difícil |
| **Función** | Límite de misiones | Consecuencia de fracasos |
| **Visual** | 4/6 ⚡ | ❤️❤️💔 |
| **Impacto** | Medio | Alto |
| **Estrés** | Bajo | Moderado |

---

**¡Sistema implementado y listo!** 🎮✨

Ahora las misiones tienen verdadero peso y enseñan:
- ✅ Responsabilidad (hacer las cosas bien)
- ✅ Estrategia (decidir qué intentar)
- ✅ Honestidad (consecuencias de no hacer)
- ✅ Autoconocimiento (cancelar cuando es difícil)
