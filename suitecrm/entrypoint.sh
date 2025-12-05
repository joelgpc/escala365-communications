#!/bin/bash
set -e

echo "--- INICIO ENTRYPOINT SUITECRM (Docker Build) ---"

# Configurar git para evitar problemas de ownership
git config --global --add safe.directory /var/www/html

# SUITECRM 8 RELEASE - Usamos release pre-construida en lugar de compilar
SUITECRM_VERSION="8.7.1"
SUITECRM_URL="https://suitecrm.com/download/147/suite87/564706/suitecrm-8-7-1.zip"

# Verificar si SuiteCRM está correctamente instalado
INSTALLED=false
if [ -f "/var/www/html/public/index.php" ] && [ -f "/var/www/html/vendor/autoload.php" ] && [ -d "/var/www/html/public/dist/suite8" ]; then
    INSTALLED=true
fi

if [ "$INSTALLED" = false ]; then
    echo ">>> Instalación incompleta o ausente. Descargando SuiteCRM ${SUITECRM_VERSION} (release pre-construida)..."
    
    # Limpiamos carpeta completamente
    rm -rf /var/www/html/* 2>/dev/null || true
    rm -rf /var/www/html/.[!.]* 2>/dev/null || true

    cd /var/www/html
    
    # Descargar release pre-construida
    echo ">>> Descargando desde ${SUITECRM_URL}..."
    curl -L -o suitecrm.zip "${SUITECRM_URL}" || {
        echo ">>> Error descargando, intentando desde GitHub releases..."
        curl -L -o suitecrm.zip "https://github.com/salesagility/SuiteCRM-Core/releases/download/v${SUITECRM_VERSION}/SuiteCRM-${SUITECRM_VERSION}.zip"
    }
    
    echo ">>> Extrayendo archivos..."
    unzip -q suitecrm.zip
    rm suitecrm.zip
    
    # Mover contenido si está en subcarpeta
    if [ -d "SuiteCRM-${SUITECRM_VERSION}" ]; then
        mv SuiteCRM-${SUITECRM_VERSION}/* .
        mv SuiteCRM-${SUITECRM_VERSION}/.[!.]* . 2>/dev/null || true
        rmdir SuiteCRM-${SUITECRM_VERSION}
    fi
    
    # Si hay subcarpeta suitecrm-8.x.x
    for dir in suitecrm-*; do
        if [ -d "$dir" ]; then
            mv "$dir"/* .
            mv "$dir"/.[!.]* . 2>/dev/null || true
            rmdir "$dir"
        fi
    done
    
    # Verificar que tenemos los archivos correctos
    if [ ! -f "composer.json" ]; then
        echo ">>> ERROR: No se encontró composer.json después de extraer"
        ls -la
        exit 1
    fi
    
    echo ">>> Ejecutando composer install..."
    export APP_ENV=prod
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs || {
        echo ">>> Advertencia: composer install tuvo problemas, continuando..."
    }
    
    # Crear directorios de cache necesarios
    echo ">>> Creando directorios de cache..."
    mkdir -p /var/www/html/cache
    mkdir -p /var/www/html/public/legacy/cache
    mkdir -p /var/www/html/public/legacy/cache/images
    mkdir -p /var/www/html/public/legacy/cache/xml
    mkdir -p /var/www/html/public/legacy/cache/modules
    mkdir -p /var/www/html/logs
    mkdir -p /var/www/html/public/legacy/upload
    
    # Ajustar permisos
    echo ">>> Ajustando permisos..."
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    chmod -R 775 /var/www/html/cache
    chmod -R 775 /var/www/html/public/legacy/cache
    chmod -R 775 /var/www/html/logs
    chmod -R 775 /var/www/html/public/legacy/upload
    
    echo ">>> Instalación completada."
else
    echo ">>> SuiteCRM ya instalado correctamente. Saltando descarga."
fi

# Asegurar permisos finales siempre al arrancar
echo ">>> Re-aplicando permisos a directorios críticos..."
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html/cache 2>/dev/null || true
chmod -R 775 /var/www/html/public/legacy/cache 2>/dev/null || true
chmod -R 775 /var/www/html/logs 2>/dev/null || true
chmod -R 775 /var/www/html/public/legacy/upload 2>/dev/null || true

# Crear .htaccess si no existe
if [ ! -f "/var/www/html/public/.htaccess" ]; then
    echo ">>> Creando .htaccess..."
    cat > /var/www/html/public/.htaccess << 'EOF'
<FilesMatch "^\.">
    Require all denied
</FilesMatch>

RewriteEngine On
RewriteBase /

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
EOF
    chown www-data:www-data /var/www/html/public/.htaccess
fi

echo "--- ENTRYPOINT FINALIZADO. ARRANCANDO APACHE ---"
exec apache2-foreground
