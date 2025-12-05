#!/bin/bash
set -e

echo "--- INICIO ENTRYPOINT SUITECRM (Docker Build) ---"

# Nota: Las dependencias de sistema y PHP ya se instalaron en el Dockerfile.

# 1. Descargar SuiteCRM si la carpeta html está vacía (o solo tiene index.php por defecto)
if [ ! -f "/var/www/html/composer.json" ]; then
    echo ">>> No se detecta instalación. Descargando SuiteCRM 8..."
    # Limpiamos carpeta con seguridad
    rm -rf /var/www/html/*
    rm -rf /var/www/html/.[!.]* 

    # Clonamos
    git clone https://github.com/salesagility/SuiteCRM-Core.git /var/www/html --depth 1
    
    echo ">>> Ejecutando composer install..."
    cd /var/www/html
    composer install --no-dev --optimize-autoloader
    
    # Ajustar permisos
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    echo ">>> Descarga completada."
else
    echo ">>> SuiteCRM ya instalado. Saltando descarga."
fi

# 2. Asegurar permisos finales siempre al arrancar
echo ">>> Re-aplicando permisos a /var/www/html..."
chown -R www-data:www-data /var/www/html

echo "--- ENTRYPOINT FINALIZADO. ARRANCANDO APACHE ---"
exec apache2-foreground
