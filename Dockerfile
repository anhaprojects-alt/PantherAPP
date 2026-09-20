FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq-dev unzip git \
    && docker-php-ext-install pdo_pgsql \
    && rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.* /etc/apache2/mods-enabled/mpm_prefork.* \
    && a2enmod mpm_prefork rewrite headers \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader \
    && chmod 0755 /usr/local/bin/docker-entrypoint.sh \
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
       '    Header always set Permissions-Policy "camera=(), microphone=(), geolocation=(self)"' \
       '    ErrorLog ${APACHE_LOG_DIR}/error.log' \
       '    CustomLog ${APACHE_LOG_DIR}/access.log combined' \
       '</VirtualHost>' > /etc/apache2/sites-available/000-default.conf \
    && apache2ctl -t \
    && test "$(apache2ctl -M 2>/dev/null | grep -Ec "mpm_(event|worker|prefork)_module")" = "1" \
    && test "$(apache2ctl -M 2>/dev/null | grep -Ec "mpm_prefork_module")" = "1"

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
