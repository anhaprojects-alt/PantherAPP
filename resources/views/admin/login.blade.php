<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Masuk Admin &middot; {{ config('app.name', 'PantherAPP') }}</title>

        <link rel="stylesheet" href="{{ asset('assets/panther.css') }}">
    </head>
    <body class="auth-body">
        <main class="auth">
            <a class="auth-brand" href="{{ route('home') }}">
                <img src="{{ asset('assets/panther-wordmark.png') }}" alt="{{ config('app.name', 'PantherAPP') }}">
            </a>

            <div class="auth-card">
                <h1>Masuk Admin</h1>
                <p class="auth-note">Halaman ini khusus administrator.</p>

                @if ($errors->any())
                    <div class="alert" role="alert">
                        <ul>
                            @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif

                <form method="POST" action="{{ route('admin.login.store') }}">
                    @csrf

                    <div class="field">
                        <label class="label" for="email">Email</label>
                        <input
                            class="input"
                            id="email"
                            name="email"
                            type="email"
                            value="{{ old('email') }}"
                            required
                            autofocus
                            autocomplete="username"
                            @error('email') aria-invalid="true" @enderror
                        >
                    </div>

                    <div class="field">
                        <label class="label" for="password">Password</label>
                        <input
                            class="input"
                            id="password"
                            name="password"
                            type="password"
                            required
                            autocomplete="current-password"
                        >
                    </div>

                    <label class="checkbox" for="remember">
                        <input id="remember" name="remember" type="checkbox" value="1" @checked(old('remember'))>
                        <span>Ingat saya</span>
                    </label>

                    <button class="btn btn-primary btn-block" type="submit">Masuk</button>
                </form>

                <p class="auth-foot">
                    <a href="{{ route('home') }}">&larr; Kembali ke halaman utama</a>
                </p>
            </div>
        </main>
    </body>
</html>
