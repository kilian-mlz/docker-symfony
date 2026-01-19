FROM php:8.2-fpm

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev libonig-dev acl \
    && docker-php-ext-install pdo_mysql intl zip opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copie du script d'entrée
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

# --- CORRECTIF MAGIQUE POUR WINDOWS ---
# Cette ligne enlève les retours à la ligne Windows (\r) qui font planter le script
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint

# On rend le script exécutable
RUN chmod +x /usr/local/bin/docker-entrypoint

WORKDIR /var/www/symfony

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]