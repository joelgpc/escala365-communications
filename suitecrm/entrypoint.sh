#!/bin/bash
set -e

echo "=== SuiteCRM Docker Entrypoint Start ==="

# Configurar git para evitar problemas de ownership
git config --global --add safe.directory /var/www/html

# Verificar si SuiteCRM está correctamente instalado
INSTALLED=false
if [ -f "/var/www/html/public/index.php" ] && [ -f "/var/www/html/vendor/autoload.php" ]; then
    INSTALLED=true
fi

if [ "$INSTALLED" = false ]; then
    echo ">>> Instalación incompleta. Instalando SuiteCRM 8..."
    
    cd /var/www/html
    
    # Limpiar directorio
    find . -maxdepth 1 ! -name '.' ! -name '..' -exec rm -rf {} + 2>/dev/null || true
    
    # Git Clone
    echo ">>> Descargando SuiteCRM 8 via Git Clone..."
    git clone --depth 1 --branch v8.7.1 https://github.com/salesagility/SuiteCRM-Core.git . || \
        git clone --depth 1 https://github.com/salesagility/SuiteCRM-Core.git .
    
    # Eliminar .git por seguridad
    rm -rf .git
    
    echo ">>> Ejecutando Composer Install (esto tarda varios minutos)..."
    export APP_ENV=prod
    export COMPOSER_ALLOW_SUPERUSER=1
    
    composer install --no-dev --optimize-autoloader --no-interaction --no-scripts --ignore-platform-reqs || true
    
    # Crear estructura de directorios necesaria
    echo ">>> Creando estructura de directorios..."
    mkdir -p cache logs
    mkdir -p public/legacy/cache/images
    mkdir -p public/legacy/cache/xml
    mkdir -p public/legacy/cache/modules
    mkdir -p public/legacy/upload
    
    echo ">>> ✓ Instalación completada."
fi

# Asegurar permisos (CRÍTICO para SuiteCRM)
echo ">>> Ajustando permisos..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \; 2>/dev/null || true
find /var/www/html -type f -exec chmod 644 {} \; 2>/dev/null || true
chmod -R 775 /var/www/html/cache 2>/dev/null || true
chmod -R 775 /var/www/html/logs 2>/dev/null || true
chmod -R 775 /var/www/html/public/legacy/cache 2>/dev/null || true
chmod -R 775 /var/www/html/public/legacy/upload 2>/dev/null || true
chmod +x /var/www/html/bin/console 2>/dev/null || true

echo "=== Starting Apache ==="
exec apache2-foreground
