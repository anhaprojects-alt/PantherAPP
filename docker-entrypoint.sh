#!/bin/sh
set -eu

: "${APP_KEY:?APP_KEY is required}"
: "${DB_CONNECTION:?DB_CONNECTION is required}"

if [ -z "${DB_URL:-}" ] && { [ -z "${DB_HOST:-}" ] || [ -z "${DB_DATABASE:-}" ] || [ -z "${DB_USERNAME:-}" ] || [ -z "${DB_PASSWORD:-}" ]; }; then
    echo "Database configuration is incomplete: set DATABASE_URL/DB_URL or DB_HOST, DB_DATABASE, DB_USERNAME and DB_PASSWORD." >&2
    exit 1
fi

mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs storage/app/member-documents bootstrap/cache

php artisan storage:link || true
php artisan migrate --force
php artisan db:seed --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

exec php -S 0.0.0.0:"${PORT:-8080}" -t public
