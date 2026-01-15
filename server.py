#!/usr/bin/env python3
"""
Servidor HTTP simple para la aplicación Heroína del Hogar
Permite acceso desde cualquier dispositivo en la red local
"""

import http.server
import socketserver
import socket
import os
import sys

# Configuración
PORT = 8000
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Handler personalizado para servir archivos estáticos"""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
    
    def end_headers(self):
        # Añadir headers para mejor compatibilidad
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()
    
    def log_message(self, format, *args):
        # Formato de log más limpio
        print(f"[{self.log_date_time_string()}] {format % args}")

def get_local_ip():
    """Obtiene la IP local de la máquina"""
    try:
        # Crear un socket temporal para obtener la IP local
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception:
        return "127.0.0.1"

def main():
    """Función principal del servidor"""
    
    # Cambiar al directorio del proyecto
    os.chdir(DIRECTORY)
    
    # Obtener IP local
    local_ip = get_local_ip()
    
    # Crear el servidor
    with socketserver.TCPServer(("", PORT), CustomHTTPRequestHandler) as httpd:
        print("=" * 70)
        print("🏰 SERVIDOR - HEROÍNA DEL HOGAR")
        print("=" * 70)
        print(f"\n✅ Servidor iniciado correctamente en el puerto {PORT}\n")
        print("📱 ACCESO DESDE DISPOSITIVOS:\n")
        print(f"   • Desde este PC:")
        print(f"     http://localhost:{PORT}")
        print(f"     http://127.0.0.1:{PORT}\n")
        print(f"   • Desde móvil/tablet (misma red WiFi):")
        print(f"     http://{local_ip}:{PORT}\n")
        print("=" * 70)
        print("\n💡 INSTRUCCIONES:")
        print("   1. Asegúrate de que todos los dispositivos estén en la misma red WiFi")
        print("   2. Abre el navegador en tu móvil/tablet")
        print(f"   3. Escribe la dirección: http://{local_ip}:{PORT}")
        print("   4. ¡Listo! Ahora puedes usar la aplicación")
        print("\n⚠️  Para detener el servidor, presiona Ctrl+C\n")
        print("=" * 70)
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\n🛑 Servidor detenido por el usuario")
            print("=" * 70)
            sys.exit(0)

if __name__ == "__main__":
    main()
