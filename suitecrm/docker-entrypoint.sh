#!/bin/bash
set -e

echo "=== SuiteCRM Docker Entrypoint ==="

# Instalar paquetes básicos solo la primera vez
if [ ! -f /var/www/html/.packages_installed ]; then
    echo "Instalando dependencias del sistema..."
    apt-get update -qq
    apt-get install -y --no-install-recommends \
        git \
        unzip \
        curl \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        default-mysql-client > /dev/null 2>&1
    
    docker-php-ext-install zip gd mysqli pdo pdo_mysql opcache > /dev/null 2>&1
    a2enmod rewrite
    
    touch /var/www/html/.packages_installed
    echo "✓ Dependencias instaladas"
fi

# Si no existe SuiteCRM, descargarlo
if [ ! -f /var/www/html/index.php ]; then
    cd /var/www/html
    rm -rf ./*
    
    echo "Descargando SuiteCRM desde GitHub..."
    git clone --depth 1 https://github.com/salesagility/SuiteCRM-Core.git . > /dev/null 2>&1
    
    echo "Instalando Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1
    
    echo "Instalando dependencias PHP (esto puede tardar 5-10 min)..."
    composer install --no-dev --optimize-autoloader --no-interaction > /dev/null 2>&1
    
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    echo "✓ SuiteCRM descargado e inicializado"
fi

# Asegurar permisos correctos siempre
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "=== Iniciando Apache ==="
exec apache2-foreground
