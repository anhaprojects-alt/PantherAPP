FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq-dev unzip git \
    && docker-php-ext-install pdo_pgsql \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader \
    && chown -R www-data:www-data storage bootstrap/cache \
    && printf '%s\n' \
       '<VirtualHost *:80>' \
       '    DocumentRoot /var/www/html/public' \
       '    <Directory /var/www/html/public>' \
       '        AllowOverride All' \
       '        Require all granted' \
       '    </Directory>' \
       '    Header always set X-Content-Type-Options "nosniff"' \
       '    Header always set X-Frame-Options "SAMEORIGIN"' \
       '    Header always set Referrer-Policy "strict-origin-when-cross-origin"' \
       '    ErrorLog ${APACHE_LOG_DIR}/error.log' \
       '    CustomLog ${APACHE_LOG_DIR}/access.log combined' \
       '</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

EXPOSE 80
CMD ["sh", "-c", "php artisan migrate --force && php artisan config:cache && php artisan route:cache && apache2-foreground"]
