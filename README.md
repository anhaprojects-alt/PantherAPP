# Panther Mania

Laravel 13 API backend for the Panther Mania Android application. The mobile client should use Kotlin + Jetpack Compose and authenticate with Laravel Sanctum tokens.

## Local development

```powershell
composer install
Copy-Item .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

Set local PostgreSQL values in `.env`. Do not commit `.env` or any Firebase Admin SDK JSON file.

## API

- `POST /api/auth/register` — multipart registration with `name`, `email`, `password`, `password_confirmation`, `phone`, `ktp_number`, `sim_number`, `ktp`, `sim`, and `payment`.
- `POST /api/auth/login` — returns a Sanctum bearer token.
- `GET /api/me` — authenticated member data.
- `PUT /api/me/profile` — authenticated profile update.
- `POST /api/auth/logout` — revoke current token.
- `GET /api/admin/members/pending` — admin only.
- `POST /api/admin/members/{member}/approve` — admin only.

Use `Authorization: Bearer <token>` for protected endpoints. Uploaded identity and payment documents are stored on the private disk and are never returned as public URLs.

## Railway deployment

Railway uses the root `Dockerfile` and `railway.toml`. Add a PostgreSQL service to the project and attach it to the Laravel service. Railway automatically injects `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, and `PGPASSWORD`; the application maps these in `.env.example`.

Configure these variables in the Laravel service:

```text
APP_NAME=Panther Mania
APP_ENV=production
APP_DEBUG=false
APP_URL=https://pantherapp-production.up.railway.app
APP_KEY=<generate with php artisan key:generate --show>
APP_FORCE_HTTPS=true
DB_CONNECTION=pgsql
DB_HOST=${{Postgres.PGHOST}}
DB_PORT=${{Postgres.PGPORT}}
DB_DATABASE=${{Postgres.PGDATABASE}}
DB_USERNAME=${{Postgres.PGUSER}}
DB_PASSWORD=${{Postgres.PGPASSWORD}}
DB_SSLMODE=require
CORS_ALLOWED_ORIGINS=https://pantherapp-production.up.railway.app
```

Use Railway's **Variables → Add Reference** menu for the exact service reference syntax. Do not hardcode the database password or the host `iriguchi.proxy.rlwy.net:22065` in source; internal Railway references are more reliable and avoid exposing credentials.

After the first deployment, create an account through the API and promote it:

```bash
php artisan panther:promote-admin admin@example.com
```

The Docker image runs migrations, caches configuration/routes, enables Apache rewrite rules, and exposes `/up` for Railway health checks. Assign `pantherapp-production.up.railway.app` to this service in Railway.
