#!/bin/bash
set -e

echo "--- INICIO ENTRYPOINT SUITECRM (Docker Build) ---"

# Configurar git para evitar problemas de ownership
git config --global --add safe.directory /var/www/html

# Verificar si SuiteCRM está correctamente instalado
# Chequeamos public/index.php que es el archivo real que sirve Apache
INSTALLED=false
if [ -f "/var/www/html/public/index.php" ] && [ -f "/var/www/html/vendor/autoload.php" ]; then
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
    
    echo ">>> Ejecutando composer install (esto puede tardar varios minutos)..."
    cd /var/www/html
    
    # Ejecutar composer install con opciones de tolerancia
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --ignore-platform-reqs || {
        echo ">>> ERROR: Composer install falló. Verificando logs..."
        exit 1
    }
    
    # Ajustar permisos
    echo ">>> Ajustando permisos..."
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    echo ">>> Instalación completada exitosamente."
else
    echo ">>> SuiteCRM ya instalado correctamente. Saltando descarga."
fi

# Asegurar permisos finales siempre al arrancar
echo ">>> Re-aplicando permisos a /var/www/html..."
chown -R www-data:www-data /var/www/html

# Crear archivo .htaccess de seguridad si no existe
if [ ! -f "/var/www/html/public/.htaccess" ]; then
    echo ">>> Creando .htaccess de seguridad en public/..."
    cat > /var/www/html/public/.htaccess << 'EOF'
# Denegar acceso a archivos sensibles
<FilesMatch "^\.">
    Require all denied
</FilesMatch>

# Habilitar rewrite
RewriteEngine On
RewriteBase /

# Reglas estándar de SuiteCRM
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
EOF
    chown www-data:www-data /var/www/html/public/.htaccess
fi

echo "--- ENTRYPOINT FINALIZADO. ARRANCANDO APACHE ---"
exec apache2-foreground
