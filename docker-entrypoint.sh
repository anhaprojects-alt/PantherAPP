#!/bin/sh
set -eu

: "${APP_KEY:?APP_KEY is required}"
: "${DB_CONNECTION:?DB_CONNECTION is required}"

if [ -z "${DB_URL:-}" ] && { [ -z "${DB_HOST:-}" ] || [ -z "${DB_DATABASE:-}" ] || [ -z "${DB_USERNAME:-}" ] || [ -z "${DB_PASSWORD:-}" ]; }; then
    echo "Database configuration is incomplete: set DATABASE_URL/DB_URL or DB_HOST, DB_DATABASE, DB_USERNAME and DB_PASSWORD." >&2
    exit 1
fi

mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache

php artisan migrate --force
php artisan config:cache
php artisan route:cache

exec php artisan serve --host=0.0.0.0 --port="${PORT:-8080}"
