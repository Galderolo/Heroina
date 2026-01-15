@echo off
chcp 65001 >nul
title Heroína del Hogar - Servidor

:: Banner
echo.
echo ══════════════════════════════════════════════════════════════
echo.
echo          🏰 HEROÍNA DEL HOGAR - SERVIDOR WINDOWS 🏰
echo.
echo ══════════════════════════════════════════════════════════════
echo.

:: Cambiar al directorio del script
cd /d "%~dp0"

:: Verificar Python
echo 🔍 Verificando Python 3...
echo.

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Python no está instalado
    echo.
    echo 📥 INSTALAR PYTHON:
    echo.
    echo   1. Ve a: https://www.python.org/downloads/
    echo   2. Descarga Python 3.x para Windows
    echo   3. Durante la instalación, marca "Add Python to PATH"
    echo   4. Vuelve a ejecutar este script
    echo.
    pause
    exit /b 1
)

python --version
echo.
echo ✅ Python encontrado
echo.

:: Verificar archivos
echo 🔍 Verificando archivos del proyecto...
echo.

if not exist "server.py" (
    echo ❌ ERROR: No se encuentra server.py
    pause
    exit /b 1
)

if not exist "index.html" (
    echo ❌ ERROR: No se encuentra index.html
    pause
    exit /b 1
)

echo ✅ Archivos verificados
echo.

:: Crear carpeta img si no existe
if not exist "img" mkdir img

:: Instrucciones
echo 📱 INSTRUCCIONES:
echo.
echo   1. El servidor se iniciará en unos segundos
echo   2. Anota la dirección IP que aparecerá
echo   3. Abre esa dirección en tu móvil/tablet
echo   4. Asegúrate de estar en la misma WiFi
echo.
echo ⚠️  Para detener el servidor: cierra esta ventana o presiona Ctrl+C
echo.

timeout /t 3 >nul

:: Iniciar servidor
echo 🚀 Iniciando servidor...
echo.

python server.py

pause
