#!/bin/bash
set -e

# Solo la primera vez: si no hay index.php, descargamos SuiteCRM
if [ ! -f /var/www/html/index.php ]; then
    cd /var/www/html
    rm -rf ./*
    echo "Descargando SuiteCRM..."
    git clone --depth 1 https://github.com/salesagility/SuiteCRM-Core.git .
    # Dependencias mínimas, más adelante afinamos
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    composer install --no-dev --optimize-autoloader
    chown -R www-data:www-data /var/www/html
fi

exec apache2-foreground
