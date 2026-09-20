<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>@yield('title', 'Panel Admin') &middot; {{ config('app.name', 'PantherAPP') }}</title>

        <link rel="stylesheet" href="{{ asset('assets/panther.css') }}">
    </head>
    <body>
        <header class="site-header">
            <div class="wrap header-inner">
                <a class="brand" href="{{ route('admin.dashboard') }}">
                    <img src="{{ asset('assets/panther-wordmark.png') }}" alt="{{ config('app.name', 'PantherAPP') }}">
                </a>

                <form method="POST" action="{{ route('admin.logout') }}">
                    @csrf
                    <button class="btn btn-ghost" type="submit">Keluar</button>
                </form>
            </div>

            <nav class="wrap admin-nav">
                <a class="nav-link @if (request()->routeIs('admin.dashboard')) is-active @endif" href="{{ route('admin.dashboard') }}">
                    Dashboard
                </a>

                <a class="nav-link @if (request()->routeIs('admin.members.*')) is-active @endif" href="{{ route('admin.members.index') }}">
                    Member
                    @isset($counts)
                        <span class="badge badge-pending">{{ $counts['pending'] }} menunggu</span>
                    @endisset
                </a>
            </nav>
        </header>

        <main class="wrap panel">
            <h1>@yield('heading')</h1>

            @hasSection('subheading')
                <p class="muted">@yield('subheading')</p>
            @endif

            @if (session('status'))
                <div class="flash" role="status">{{ session('status') }}</div>
            @endif

            @yield('content')
        </main>
    </body>
</html>
