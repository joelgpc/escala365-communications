#!/bin/bash
set -e

echo "--- INICIO ENTRYPOINT SUITECRM (ARM64 Compatible) ---"

# 1. Instalar dependencias del sistema necesarias para SuiteCRM
#    (Se hace en runtime para mantener la imagen base ligera y compatible)
echo ">>> Actualizando apt y paquetes..."
apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libimap-dev \
    libkerberos-dev \
    libkrb5-dev \
    libssl-dev \
    zlib1g-dev \
    mariadb-client \
    --no-install-recommends

# 2. Configurar e instalar extensiones de PHP
echo ">>> Instalando extensiones PHP..."
docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-configure imap --with-kerberos --with-imap-ssl
docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mysqli \
    zip \
    gd \
    imap \
    bcmath \
    soap \
    intl

# 3. Instalar Composer (gestor de paquetes PHP)
if [ ! -f "/usr/local/bin/composer" ]; then
    echo ">>> Instalando Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
fi

# 4. Configurar Apache (mod_rewrite es vital para SuiteCRM)
echo ">>> Activando mod_rewrite..."
a2enmod rewrite

# 5. Descargar SuiteCRM si la carpeta está vacía
if [ ! -f "/var/www/html/index.php" ]; then
    echo ">>> No se detecta instalación. Descargando SuiteCRM 8..."
    # Borramos html por si acaso está creado por defecto
    rm -rf /var/www/html/*
    
    # Clonamos la versión 8 (Core)
    git clone https://github.com/salesagility/SuiteCRM-Core.git /var/www/html --depth 1
    
    echo ">>> Ejecutando composer install (esto puede tardar unos minutos)..."
    cd /var/www/html
    # Instalar dependencias ignorando warnings de plataforma por si acaso
    composer install --no-dev --optimize-autoloader
    
    # Ajustar permisos iniciales
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    echo ">>> Descarga completada."
else
    echo ">>> SuiteCRM ya instalado. Saltando descarga."
fi

# 6. Asegurar permisos finales
echo ">>> Ajustando permisos..."
chown -R www-data:www-data /var/www/html

echo "--- ENTRYPOINT FINALIZADO. ARRANCANDO APACHE ---"
exec apache2-foreground
