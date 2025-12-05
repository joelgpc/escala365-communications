#!/bin/bash
set -e

# Instalar extensiones PHP necesarias
apt-get update
apt-get install -y --no-install-recommends \
    git \
    unzip \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    mysql-client

# Instalar extensiones PHP
docker-php-ext-install \
    zip \
    gd \
    mysqli \
    pdo \
    pdo_mysql \
    opcache

# Habilitar mod_rewrite
a2enmod rewrite

# Si SuiteCRM no está instalado, descargarlo
if [ ! -f /var/www/html/config.php ]; then
    cd /var/www/html
    rm -rf *
    
    echo "Descargando SuiteCRM..."
    git clone --depth 1 https://github.com/salesagility/SuiteCRM-Core.git .
    
    echo "Instalando dependencias con Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    composer install --no-dev --optimize-autoloader
    
    # Crear carpeta config
    mkdir -p config
    
    # Permisos
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
fi

# Asegurar permisos siempre
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

exec "$@"
