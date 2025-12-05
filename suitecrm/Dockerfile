FROM php:8.1-apache

# 1. Instalar dependencias del sistema (Build Time)
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

# 2. Instalar extensiones PHP (Build Time)
# Incluimos LDAP y SOAP que son requeridos por SuiteCRM 8
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

# 5. Activar Mod Rewrite
RUN a2enmod rewrite

# 6. Configurar Apache para servir desde /var/www/html/public (SuiteCRM 8 requirement)
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# 7. Configuración de seguridad para Apache
RUN echo '<Directory /var/www/html/public>\n\
    Options -Indexes +FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
    </Directory>\n\
    <FilesMatch "^\.">\n\
    Require all denied\n\
    </FilesMatch>\n\
    <DirectoryMatch "/\.git">\n\
    Require all denied\n\
    </DirectoryMatch>' > /etc/apache2/conf-available/security-custom.conf \
    && a2enconf security-custom

# 8. Establecer APP_ENV para producción
ENV APP_ENV=prod

# 9. Copiar el Entrypoint al interior de la imagen
COPY suitecrm/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 10. Definir el entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
