#!/bin/bash

# Script de inicio automático con instalación de Python si es necesario
# Compatible con Ubuntu/Debian, Fedora/RHEL, macOS

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
echo "║          🏰 HEROÍNA DEL HOGAR - INSTALADOR AUTOMÁTICO 🏰     ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Cambiar al directorio del script
cd "$(dirname "$0")"

# Función para detectar el sistema operativo
detectar_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        elif [ -f /etc/arch-release ]; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Función para instalar Python según el sistema operativo
instalar_python() {
    local os=$(detectar_os)
    
    echo -e "${YELLOW}🔧 Instalando Python 3...${NC}"
    echo ""
    
    case $os in
        "debian")
            echo -e "${CYAN}Sistema: Debian/Ubuntu${NC}"
            echo -e "${YELLOW}Se requieren permisos de administrador (sudo)${NC}"
            sudo apt update
            sudo apt install -y python3 python3-pip
            ;;
        "redhat")
            echo -e "${CYAN}Sistema: Fedora/RHEL/CentOS${NC}"
            echo -e "${YELLOW}Se requieren permisos de administrador (sudo)${NC}"
            sudo dnf install -y python3 python3-pip || sudo yum install -y python3 python3-pip
            ;;
        "arch")
            echo -e "${CYAN}Sistema: Arch Linux${NC}"
            echo -e "${YELLOW}Se requieren permisos de administrador (sudo)${NC}"
            sudo pacman -S --noconfirm python python-pip
            ;;
        "macos")
            echo -e "${CYAN}Sistema: macOS${NC}"
            if command -v brew &> /dev/null; then
                echo -e "${GREEN}✅ Homebrew encontrado${NC}"
                brew install python3
            else
                echo -e "${RED}❌ Homebrew no encontrado${NC}"
                echo -e "${YELLOW}Por favor, instala Homebrew primero:${NC}"
                echo -e "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                echo ""
                echo -e "${YELLOW}O descarga Python desde: https://www.python.org/downloads/${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "${RED}❌ Sistema operativo no reconocido${NC}"
            echo -e "${YELLOW}Por favor, instala Python 3 manualmente desde:${NC}"
            echo -e "  https://www.python.org/downloads/"
            return 1
            ;;
    esac
    
    return 0
}

# Verificar si Python 3 está instalado
echo -e "${CYAN}🔍 Verificando Python 3...${NC}"
echo ""

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✅ Python 3 encontrado: $PYTHON_VERSION${NC}"
    echo ""
else
    echo -e "${RED}❌ Python 3 no está instalado${NC}"
    echo ""
    
    # Preguntar si quiere instalar
    read -p "¿Deseas instalar Python 3 automáticamente? (s/n): " respuesta
    
    if [[ "$respuesta" =~ ^[SsYy]$ ]]; then
        if instalar_python; then
            echo ""
            echo -e "${GREEN}✅ Python 3 instalado correctamente${NC}"
            echo ""
        else
            echo ""
            echo -e "${RED}❌ No se pudo instalar Python automáticamente${NC}"
            echo -e "${YELLOW}Por favor, instálalo manualmente y vuelve a ejecutar este script${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Instalación cancelada${NC}"
        echo ""
        echo -e "${CYAN}Para instalar Python manualmente:${NC}"
        echo ""
        echo -e "  ${YELLOW}Ubuntu/Debian:${NC}"
        echo -e "    sudo apt update && sudo apt install python3"
        echo ""
        echo -e "  ${YELLOW}Fedora/RHEL:${NC}"
        echo -e "    sudo dnf install python3"
        echo ""
        echo -e "  ${YELLOW}macOS:${NC}"
        echo -e "    brew install python3"
        echo ""
        echo -e "  ${YELLOW}O descarga desde:${NC}"
        echo -e "    https://www.python.org/downloads/"
        echo ""
        exit 1
    fi
fi

# Verificar que los archivos necesarios existen
echo -e "${CYAN}🔍 Verificando archivos del proyecto...${NC}"
echo ""

archivos_necesarios=("server.py" "index.html" "misiones.html" "tienda.html" "js/data.js" "js/game.js" "js/storage.js" "css/styles.css")
archivos_faltantes=()

for archivo in "${archivos_necesarios[@]}"; do
    if [ ! -f "$archivo" ]; then
        archivos_faltantes+=("$archivo")
    fi
done

if [ ${#archivos_faltantes[@]} -gt 0 ]; then
    echo -e "${RED}❌ ERROR: Faltan archivos necesarios:${NC}"
    for archivo in "${archivos_faltantes[@]}"; do
        echo -e "  - $archivo"
    done
    echo ""
    echo -e "${YELLOW}Asegúrate de copiar toda la carpeta del proyecto${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Todos los archivos verificados${NC}"
echo ""

# Crear carpeta img si no existe
if [ ! -d "img" ]; then
    mkdir -p img
    echo -e "${YELLOW}📁 Carpeta 'img' creada${NC}"
fi

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
