FROM php:8.1-apache

# 1. Instalar dependencias del sistema (Build Time - Se hace una sola vez)
RUN apt-get update && apt-get install -y \
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
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar extensiones PHP (Build Time)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli zip gd imap bcmath soap intl

# 3. Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# 4. Activar Mod Rewrite
RUN a2enmod rewrite

# 5. Copiar el Entrypoint al interior de la imagen
# (Esto soluciona tu error: el archivo YA estará dentro, no es un volumen externo)
COPY suitecrm/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 6. Definir el entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
