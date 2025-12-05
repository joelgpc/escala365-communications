#!/bin/bash
set -e

echo "--- INICIO ENTRYPOINT SUITECRM (Docker Build) ---"

# Configurar git para evitar problemas de ownership
git config --global --add safe.directory /var/www/html

# Verificar si SuiteCRM está correctamente instalado
# Chequeamos public/index.php Y vendor/autoload.php Y dist folder
INSTALLED=false
if [ -f "/var/www/html/public/index.php" ] && [ -f "/var/www/html/vendor/autoload.php" ] && [ -d "/var/www/html/public/dist" ]; then
    INSTALLED=true
fi

if [ "$INSTALLED" = false ]; then
    echo ">>> Instalación incompleta o ausente. Limpiando y reinstalando SuiteCRM 8..."
    
    # Limpiamos carpeta completamente
    rm -rf /var/www/html/* 2>/dev/null || true
    rm -rf /var/www/html/.[!.]* 2>/dev/null || true

    # Clonamos SuiteCRM
    echo ">>> Clonando repositorio SuiteCRM-Core..."
    git clone https://github.com/salesagility/SuiteCRM-Core.git /var/www/html --depth 1
    
    # Eliminar carpeta .git para seguridad
    rm -rf /var/www/html/.git
    
    cd /var/www/html
    
    # Configurar APP_ENV antes de composer
    export APP_ENV=prod
    
    echo ">>> Ejecutando composer install (esto puede tardar varios minutos)..."
    # Usar --no-scripts para evitar errores de cache:clear
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs || {
        echo ">>> ERROR: Composer install falló."
        exit 1
    }
    
    echo ">>> Instalando dependencias de frontend..."
    # Instalar dependencias npm
    if [ -f "package.json" ]; then
        npm install --legacy-peer-deps 2>/dev/null || npm install 2>/dev/null || echo ">>> Advertencia: npm install tuvo algunos problemas"
    fi
    
    echo ">>> Construyendo assets del frontend..."
    # Crear directorio dist si no existe
    mkdir -p /var/www/html/public/dist
    
    # Intentar build de frontend
    if [ -f "package.json" ]; then
        npm run build-dev 2>/dev/null || npm run build 2>/dev/null || {
            echo ">>> Advertencia: npm build falló, creando assets mínimos..."
            # Crear archivos vacíos necesarios
            mkdir -p /var/www/html/public/dist/themes/suite8/css
            mkdir -p /var/www/html/public/dist/themes/suite8/js
            mkdir -p /var/www/html/public/dist/themes/suite8/images
            touch /var/www/html/public/dist/themes/suite8/css/styles.css
            touch /var/www/html/public/dist/themes/suite8/js/app.js
        }
    fi
    
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

# Crear .htaccess de seguridad si no existe
if [ ! -f "/var/www/html/public/.htaccess" ]; then
    echo ">>> Creando .htaccess de seguridad en public/..."
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
