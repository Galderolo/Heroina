# 📦 Guía de Portabilidad - Heroína del Hogar

## ✅ Respuesta Rápida

**¿Puedo copiar la carpeta a otro PC?**
- ✅ **SÍ**, simplemente copia toda la carpeta y funcionará

**¿Puedo usarlo en iPhone?**
- ✅ **SÍ**, pero necesitas un servidor ejecutándose en otro dispositivo
- ❌ **NO** puedes ejecutarlo directamente desde el iPhone (sin instalar apps adicionales)

---

## 📁 Cómo Copiar a Otro PC

### Paso 1: Copiar la Carpeta Completa

Copia **toda la carpeta** `/home/david/Escritorio/Rol` al otro PC usando:

- **USB/Pendrive**: Arrastra la carpeta al USB y luego al otro PC
- **Compresión**: 
  ```bash
  cd /home/david/Escritorio
  zip -r HeroinaDelHogar.zip Rol/
  ```
- **Red local**: Usar carpetas compartidas
- **Email/Cloud**: Comprimir y enviar (la carpeta pesa muy poco, ~100KB sin imágenes)

### Paso 2: En el Otro PC

#### 🐧 Si es Linux/Mac:

1. Descomprime/copia la carpeta donde quieras
2. Abre una terminal
3. Ejecuta:
   ```bash
   cd /ruta/a/la/carpeta/Rol
   ./iniciar_auto.sh
   ```
4. Si Python no está instalado, el script te ofrecerá instalarlo automáticamente

#### 🪟 Si es Windows:

1. Descomprime/copia la carpeta donde quieras
2. Haz **doble clic** en: `iniciar_windows.bat`
3. Si Python no está instalado:
   - El script te mostrará el enlace de descarga
   - Ve a https://www.python.org/downloads/
   - Descarga e instala Python (marca "Add Python to PATH")
   - Vuelve a ejecutar `iniciar_windows.bat`

---

## 📱 Cómo Usar en iPhone/iPad

El iPhone **NO puede ejecutar Python directamente**, pero puedes usar la app desde iPhone de estas formas:

### Opción 1: Servidor en otro dispositivo (RECOMENDADO) ✅

1. **Ejecuta el servidor** en cualquiera de estos dispositivos:
   - PC Windows
   - Mac
   - Linux
   - Raspberry Pi
   - Cualquier ordenador en tu casa

2. **Anota la IP** que muestra el servidor, por ejemplo:
   ```
   http://192.168.1.100:8000
   ```

3. **En tu iPhone/iPad**:
   - Conéctate a la **misma WiFi**
   - Abre Safari (o Chrome/Firefox)
   - Escribe la dirección: `http://192.168.1.100:8000`
   - ¡Listo! Funciona perfectamente

4. **(Opcional) Añadir a pantalla de inicio**:
   - En Safari, pulsa el botón "Compartir" ⬆️
   - Selecciona "Añadir a pantalla de inicio"
   - Ahora tendrás un icono como si fuera una app

### Opción 2: Servidor en el propio iPhone (Avanzado) ⚙️

Si realmente quieres ejecutarlo **solo en el iPhone** sin otro dispositivo:

#### Usando "a-Shell" (Gratis)

1. Descarga "a-Shell" desde App Store (gratis)
2. Abre a-Shell
3. Copia los archivos a la carpeta de a-Shell:
   ```bash
   mkdir heroinahogar
   cd heroinahogar
   # Copiar archivos manualmente o usar iCloud
   ```
4. Ejecuta:
   ```bash
   python3 server.py
   ```
5. Abre Safari en: `http://localhost:8000`

**Limitaciones**: Es más complicado y menos práctico que usar un servidor externo.

---

## 🌐 Configuración de Red

### IP Local vs Localhost

- **localhost (127.0.0.1)**: Solo accesible desde el mismo dispositivo
- **IP Local (ej: 192.168.1.100)**: Accesible desde toda tu red WiFi

### Cómo Encontrar tu IP Local

#### Linux:
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```
o
```bash
hostname -I
```

#### Mac:
```bash
ipconfig getifaddr en0
```
o desde Preferencias del Sistema → Red

#### Windows:
```cmd
ipconfig
```
Busca "Dirección IPv4"

### Firewall

Si no puedes acceder desde otros dispositivos:

#### Linux (UFW):
```bash
sudo ufw allow 8000
```

#### Windows:
1. Panel de Control → Firewall de Windows
2. Configuración avanzada → Reglas de entrada
3. Nueva regla → Puerto → TCP → 8000

#### Mac:
1. Preferencias del Sistema → Seguridad y privacidad
2. Firewall → Opciones
3. Permitir conexiones entrantes para Python

---

## 💾 Datos y Sincronización

### ¿Los datos se comparten entre dispositivos?

**NO automáticamente**. Cada navegador tiene su propia copia:

- PC Chrome: Sus propios datos
- iPhone Safari: Sus propios datos
- Tablet Firefox: Sus propios datos

### ¿Cómo usar un único perfil?

**Solución: Usa siempre el mismo dispositivo y navegador**

Recomendación:
1. Elige **un dispositivo principal** (ej: tablet familiar)
2. Úsalo siempre para gestionar las misiones
3. Otros dispositivos pueden **consultar** pero no modificar

### ¿Cómo hacer backup?

Los datos están en el **localStorage del navegador**. Para hacer backup:

1. Abre la consola del navegador (F12)
2. Ve a "Application" o "Almacenamiento" → "Local Storage"
3. Busca la key: `heroina_del_hogar_data`
4. Copia el valor (JSON) y guárdalo en un archivo

Para restaurar: pega el valor de vuelta.

---

## 🚀 Escenarios de Uso

### Escenario 1: Casa con un PC fijo

```
1. PC ejecuta el servidor (siempre encendido o cuando se necesite)
2. Toda la familia accede desde sus móviles/tablets
3. Usa un único dispositivo (tablet) para gestionar misiones
```

### Escenario 2: Laptop portátil

```
1. Laptop ejecuta el servidor cuando estés en casa
2. Accede desde móviles cuando el laptop esté encendido
3. Puedes llevar el laptop a otra casa y seguir usándolo
```

### Escenario 3: Raspberry Pi (Siempre disponible)

```
1. Instala en una Raspberry Pi que esté siempre encendida
2. Toda la familia accede 24/7
3. La IP nunca cambia, puedes guardarla en favoritos
```

### Escenario 4: Solo iPad/iPhone

```
1. Instala a-Shell en el iPad
2. Copia los archivos
3. Ejecuta el servidor solo cuando necesites
4. O mejor: usa Opción 1 con un Mac/PC
```

---

## 📋 Checklist de Portabilidad

Antes de copiar a otro PC, verifica:

- [ ] Copiar **toda la carpeta** completa
- [ ] No faltan archivos (especialmente en `js/` y `css/`)
- [ ] El otro PC tiene Python 3 (o usa `iniciar_auto.sh`)
- [ ] Ambos dispositivos están en la **misma red WiFi**
- [ ] El firewall permite conexiones al puerto 8000
- [ ] Sabes la IP local del servidor

---

## 🛠️ Solución de Problemas

### "No puedo acceder desde el móvil"

1. Verifica que ambos estén en la misma WiFi
2. Usa la IP correcta (no `localhost` sino `192.168.x.x`)
3. Comprueba el firewall
4. Intenta desde otro navegador en el móvil

### "Python no se encuentra (Windows)"

1. Descarga desde: https://www.python.org/downloads/
2. Durante instalación: ✅ marca "Add Python to PATH"
3. Reinicia la terminal/cmd
4. Ejecuta de nuevo

### "Los datos desaparecieron"

- ¿Usaste modo incógnito? Los datos no se guardan
- ¿Cambiaste de navegador? Cada navegador tiene sus datos
- ¿Limpiaste cookies? Se borraron los datos
- Usa siempre el mismo navegador y dispositivo

### "El servidor se detiene solo"

- No cierres la terminal/ventana
- Si apagas el PC, el servidor se detiene
- Considera usar Raspberry Pi para servidor 24/7

---

## 📱 Apps Alternativas para iOS

Si quieres ejecutar Python en iPhone/iPad:

1. **a-Shell** (Gratis): Terminal completo con Python
   - App Store: https://apps.apple.com/app/a-shell/id1473805438

2. **Pythonista** (De pago ~10€): IDE Python completo
   - App Store: https://apps.apple.com/app/pythonista-3/id1085978097

3. **Juno** (Gratis): Jupyter notebooks
   - Menos recomendado para este proyecto

---

## 🎯 Recomendación Final

**Para máxima facilidad:**

1. Ejecuta el servidor en un **PC/Mac/Raspberry Pi** que esté en casa
2. Accede desde **iPad/iPhone** vía navegador
3. Usa el iPad como dispositivo principal para gestionar misiones
4. Añade un marcador en Safari para acceso rápido
5. ¡Disfruta sin complicaciones técnicas!

**No recomiendo** ejecutar el servidor en el iPhone salvo que tengas experiencia técnica.

---

## 📞 Resumen Ejecutivo

| Pregunta | Respuesta |
|----------|-----------|
| ¿Copiar carpeta a otro PC? | ✅ Sí, funciona directamente |
| ¿Usar en iPhone abriendo index.html? | ❌ No, necesita servidor |
| ¿Usar en iPhone con servidor externo? | ✅ Sí, perfectamente |
| ¿Instalar Python automáticamente? | ✅ Sí, con `iniciar_auto.sh` |
| ¿Sincronizar datos entre dispositivos? | ❌ No automático, usa un solo dispositivo |
| ¿Funciona sin internet? | ✅ Sí, solo necesita red local |

---

**¿Más dudas?** Lee el `README.md` o el `INSTRUCCIONES_RAPIDAS.txt`
