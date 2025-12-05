#!/bin/bash
set -e

echo "--- INICIO ENTRYPOINT SUITECRM (Fix ARM64) ---"

# Verificamos si ya está instalado mirando si existe el index.php
if [ ! -f "/var/www/html/public/index.php" ]; then
    echo ">>> Instalación limpia detectada (o corrupta). Iniciando despliegue..."
    
    # 1. Limpiar directorio (por si quedó basura de intentos anteriores)
    find /var/www/html -mindepth 1 -delete 2>/dev/null || true
    
    # 2. Descargar el ZIP OFICIAL (Pre-compilado) desde GitHub
    # Este ZIP ya trae el frontend de Angular compilado en la carpeta /dist
    ZIP_URL="https://github.com/salesagility/SuiteCRM-Core/releases/download/v8.7.1/SuiteCRM-8.7.1.zip"
    
    echo ">>> Descargando Release 8.7.1 (con pre-compiled assets)..."
    curl -L -f -o /tmp/suitecrm.zip "$ZIP_URL"
    
    if [ ! -s /tmp/suitecrm.zip ]; then
        echo "ERROR CRÍTICO: El ZIP descargado está vacío. Revisa la conexión."
        exit 1
    fi

    echo ">>> Descomprimiendo..."
    unzip -q /tmp/suitecrm.zip -d /var/www/html/
    
    # Limpieza
    rm /tmp/suitecrm.zip
    
    # 3. Instalación de dependencias de PHP (Backend)
    echo ">>> Ejecutando composer install..."
    cd /var/www/html
    # --ignore-platform-reqs es vital en ARM por si alguna librería pide extensiones raras
    composer install --no-dev --optimize-autoloader --ignore-platform-reqs
    
    echo ">>> Ajustando permisos propietarios (Vital para SuiteCRM 8)..."
    chown -R www-data:www-data /var/www/html
    
    # Permisos específicos recomendados por SuiteCRM
    find . -type d -not -perm 2755 -exec chmod 2755 {} \;
    find . -type f -not -perm 0644 -exec chmod 0644 {} \;
    find . ! -user www-data -exec chown www-data:www-data {} \;
    chmod +x bin/console
    
    echo ">>> Despliegue de archivos completado."
else
    echo ">>> SuiteCRM ya parece instalado. Saltando descarga."
    # Siempre aseguramos permisos al arrancar por si acaso
    chown -R www-data:www-data /var/www/html
fi

echo "--- ENTRYPOINT FINALIZADO. ARRANCANDO APACHE ---"
exec apache2-foreground
