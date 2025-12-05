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
    mariadb-client \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar extensiones PHP (Build Time)
# Incluimos LDAP que es requerido por SuiteCRM 8
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli zip gd bcmath intl ldap

# 3. Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# 4. Activar Mod Rewrite
RUN a2enmod rewrite

# 5. Configuración de seguridad para Apache (denegar acceso a .git, .env, etc.)
RUN echo '<Directory /var/www/html>\n\
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

# 6. Copiar el Entrypoint al interior de la imagen
COPY suitecrm/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 7. Definir el entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
