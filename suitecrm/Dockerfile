FROM php:8.1-apache

# 1. Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libssl-dev \
    zlib1g-dev \
    libicu-dev \
    libldap2-dev \
    libxml2-dev \
    mariadb-client \
    curl \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar extensiones PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli zip gd bcmath intl ldap soap

# 3. Configurar PHP para SuiteCRM
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/suitecrm.ini \
    && echo "upload_max_filesize = 20M" >> /usr/local/etc/php/conf.d/suitecrm.ini \
    && echo "post_max_size = 25M" >> /usr/local/etc/php/conf.d/suitecrm.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/suitecrm.ini \
    && echo "max_input_time = 300" >> /usr/local/etc/php/conf.d/suitecrm.ini

# 4. Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# 5. Configurar Apache - Habilitar módulos
RUN a2enmod rewrite headers expires

# 6. FIX VITAL: Inyectar nuestra configuración de VHOST con AllowOverride All
COPY suitecrm/000-default.conf /etc/apache2/sites-available/000-default.conf

# 7. Establecer APP_ENV para producción
ENV APP_ENV=prod

# 8. Copiar el Entrypoint
COPY suitecrm/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 9. Definir el entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
