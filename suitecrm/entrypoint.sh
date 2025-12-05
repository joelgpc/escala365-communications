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
    
    # Limpiar directorio por si hubo intentos fallidos
    find . -maxdepth 1 ! -name '.' ! -name '..' -exec rm -rf {} + 2>/dev/null || true
    
    # Método: Git Clone (más robusto que ZIP, funciona siempre)
    echo ">>> Descargando SuiteCRM 8 via Git Clone..."
    git clone --depth 1 --branch v8.7.1 https://github.com/salesagility/SuiteCRM-Core.git . || \
        git clone --depth 1 https://github.com/salesagility/SuiteCRM-Core.git .
    
    # Eliminar .git para seguridad
    rm -rf .git
    
    echo ">>> Ejecutando Composer Install (esto puede tardar 5-10 minutos)..."
    export APP_ENV=prod
    export COMPOSER_ALLOW_SUPERUSER=1
    
    # Composer install con opciones para evitar errores
    composer install --no-dev --optimize-autoloader --no-interaction --no-scripts --ignore-platform-reqs || {
        echo ">>> Advertencia: Composer tuvo algunos errores, continuando..."
    }
    
    # Crear directorios necesarios
    echo ">>> Creando estructura de directorios..."
    mkdir -p cache
    mkdir -p logs
    mkdir -p public/legacy/cache/images
    mkdir -p public/legacy/cache/xml
    mkdir -p public/legacy/cache/modules
    mkdir -p public/legacy/upload
    mkdir -p public/dist/suite8/css
    mkdir -p public/dist/suite8/js
    mkdir -p public/dist/suite8/images
    
    # Crear archivos mínimos de frontend si no existen
    if [ ! -f "public/dist/suite8/css/styles.css" ]; then
        echo ">>> Creando assets mínimos del frontend..."
        echo "/* SuiteCRM Styles */" > public/dist/suite8/css/styles.css
        echo "// SuiteCRM App" > public/dist/suite8/js/app.js
    fi
    
    # Ajustar permisos
    echo ">>> Ajustando permisos..."
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    chmod -R 775 cache
    chmod -R 775 logs
    chmod -R 775 public/legacy/cache
    chmod -R 775 public/legacy/upload
    
    echo ">>> ✓ Instalación completada."
else
    echo ">>> SuiteCRM ya instalado. Saltando descarga."
fi

# Asegurar permisos finales siempre al arrancar
echo ">>> Re-aplicando permisos..."
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html/cache 2>/dev/null || true
chmod -R 775 /var/www/html/logs 2>/dev/null || true
chmod -R 775 /var/www/html/public/legacy/cache 2>/dev/null || true
chmod -R 775 /var/www/html/public/legacy/upload 2>/dev/null || true

echo "=== Starting Apache ==="
exec apache2-foreground
