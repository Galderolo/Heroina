#!/bin/bash

# Script de inicio rápido para Heroína del Hogar

# Colores para el terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# Banner
echo -e "${MAGENTA}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║          🏰 HEROÍNA DEL HOGAR - INICIO RÁPIDO 🏰             ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Cambiar al directorio del script
cd "$(dirname "$0")"

# Verificar que Python 3 esté instalado
if ! command -v python3 &> /dev/null
then
    echo -e "${RED}❌ ERROR: Python 3 no está instalado${NC}"
    echo -e "${YELLOW}Por favor, instala Python 3 para continuar${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Python 3 encontrado${NC}"
echo ""

# Verificar que los archivos necesarios existen
if [ ! -f "server.py" ]; then
    echo -e "${RED}❌ ERROR: No se encuentra server.py${NC}"
    exit 1
fi

if [ ! -f "index.html" ]; then
    echo -e "${RED}❌ ERROR: No se encuentra index.html${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Archivos verificados${NC}"
echo ""

# Mostrar instrucciones
echo -e "${CYAN}📱 INSTRUCCIONES:${NC}"
echo ""
echo -e "  1. El servidor se iniciará en unos segundos"
echo -e "  2. Anota la dirección IP que aparecerá"
echo -e "  3. Abre esa dirección en tu móvil/tablet"
echo -e "  4. Asegúrate de estar en la misma WiFi"
echo ""
echo -e "${YELLOW}⚠️  Para detener el servidor: presiona Ctrl+C${NC}"
echo ""

# Pequeña pausa para que se lean las instrucciones
sleep 3

# Iniciar el servidor
echo -e "${GREEN}🚀 Iniciando servidor...${NC}"
echo ""

python3 server.py
