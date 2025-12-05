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
    
    # Eliminar .git
    rm -rf .git
    
    echo ">>> Ejecutando Composer Install..."
    export APP_ENV=prod
    export COMPOSER_ALLOW_SUPERUSER=1
    
    composer install --no-dev --optimize-autoloader --no-interaction --no-scripts --ignore-platform-reqs || true
    
    # Crear estructura de directorios
    echo ">>> Creando estructura de directorios..."
    mkdir -p cache logs
    mkdir -p public/legacy/cache/images
    mkdir -p public/legacy/cache/xml
    mkdir -p public/legacy/cache/modules
    mkdir -p public/legacy/upload
    
    echo ">>> ✓ Instalación completada."
fi

# CONFIGURAR APACHE VHOST (CRÍTICO PARA CSS)
echo ">>> Configurando Apache VHost..."
cat > /etc/apache2/sites-available/000-default.conf << 'APACHE_CONF'
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/public
    
    <Directory /var/www/html/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Permitir acceso a legacy
    <Directory /var/www/html/public/legacy>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
APACHE_CONF

# Habilitar mod_rewrite
a2enmod rewrite > /dev/null 2>&1 || true

# Asegurar permisos
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
