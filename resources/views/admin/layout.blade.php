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
                    <img src="{{ asset('assets/panther-wordmark-alpha.png') }}" alt="{{ config('app.name', 'PantherAPP') }}">
                </a>

                <form method="POST" action="{{ route('admin.logout') }}">
                    @csrf
                    <button class="btn btn-ghost" type="submit">Keluar</button>
                </form>
            </div>

            <nav class="wrap admin-nav" aria-label="Navigasi panel">
                <a
                    class="nav-link @if (request()->routeIs('admin.dashboard')) is-active @endif"
                    href="{{ route('admin.dashboard') }}"
                    @if (request()->routeIs('admin.dashboard')) aria-current="page" @endif
                >
                    Dashboard
                </a>

                <a
                    class="nav-link @if (request()->routeIs('admin.members.*')) is-active @endif"
                    href="{{ route('admin.members.index') }}"
                    @if (request()->routeIs('admin.members.*')) aria-current="page" @endif
                >
                    Member
                    @isset($counts)
                        <span class="badge badge-pending">{{ $counts['pending'] }} menunggu</span>
                    @endisset
                </a>
            </nav>
        </header>

        <main class="wrap panel">
            <div class="page-head">
                <div>
                    <h1 class="page-title">@yield('heading')</h1>

                    @hasSection('subheading')
                        <p class="page-sub">@yield('subheading')</p>
                    @endif
                </div>
            </div>

            @if (session('status'))
                <div class="flash" role="status">{{ session('status') }}</div>
            @endif

            @yield('content')
        </main>
    </body>
</html>
