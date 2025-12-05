#!/bin/bash
set -e

echo "--- INICIO ENTRYPOINT SUITECRM (Docker Build) ---"

# Configurar git para evitar problemas de ownership
git config --global --add safe.directory /var/www/html

# 1. Descargar SuiteCRM si la carpeta html está vacía
if [ ! -f "/var/www/html/composer.json" ]; then
    echo ">>> No se detecta instalación. Descargando SuiteCRM 8..."
    # Limpiamos carpeta con seguridad
    rm -rf /var/www/html/*
    rm -rf /var/www/html/.[!.]* 2>/dev/null || true

    # Clonamos SuiteCRM
    git clone https://github.com/salesagility/SuiteCRM-Core.git /var/www/html --depth 1
    
    echo ">>> Ejecutando composer install..."
    cd /var/www/html
    
    # Intentar composer install, con fallback para ignorar extensiones faltantes
    composer install --no-dev --optimize-autoloader || \
        composer install --no-dev --optimize-autoloader --ignore-platform-reqs
    
    # Eliminar carpeta .git para seguridad
    rm -rf /var/www/html/.git
    
    # Ajustar permisos
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    echo ">>> Descarga completada."
else
    echo ">>> SuiteCRM ya instalado. Saltando descarga."
    # Asegurar que no exista .git
    rm -rf /var/www/html/.git 2>/dev/null || true
fi

# 2. Asegurar permisos finales siempre al arrancar
echo ">>> Re-aplicando permisos a /var/www/html..."
chown -R www-data:www-data /var/www/html

# 3. Crear archivo .htaccess de seguridad si no existe
if [ ! -f "/var/www/html/.htaccess" ]; then
    echo ">>> Creando .htaccess de seguridad..."
    cat > /var/www/html/.htaccess << 'EOF'
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
    chown www-data:www-data /var/www/html/.htaccess
fi

echo "--- ENTRYPOINT FINALIZADO. ARRANCANDO APACHE ---"
exec apache2-foreground
