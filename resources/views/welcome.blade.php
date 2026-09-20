<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>{{ config('app.name', 'PantherAPP') }}</title>
        <meta name="description" content="PantherAPP — pendaftaran dan keanggotaan komunitas Panther.">

        <link rel="stylesheet" href="{{ asset('assets/panther.css') }}">
    </head>
    <body>
        <header class="site-header">
            <div class="wrap header-inner">
                <a class="brand" href="{{ route('home') }}">
                    <img src="{{ asset('assets/panther-wordmark.png') }}" alt="{{ config('app.name', 'PantherAPP') }}">
                </a>

                <a class="btn btn-ghost" href="{{ route('admin.login') }}">Masuk Admin</a>
            </div>
        </header>

        <main>
            <section class="hero">
                <div class="wrap hero-grid">
                    <div>
                        <h1 class="hero-title">Komunitas Panther dalam satu aplikasi</h1>

                        <p class="hero-lead">
                            Daftar sebagai anggota, unggah dokumen yang dibutuhkan, lalu tunggu
                            verifikasi admin. Pengajuan yang disetujui mendapat nomor anggota resmi.
                        </p>

                        <div class="hero-actions">
                            <a class="btn btn-primary" href="{{ route('admin.login') }}">Masuk Admin</a>
                            <a class="btn btn-ghost" href="#alur">Lihat alur pendaftaran</a>
                        </div>
                    </div>

                    <div class="hero-media">
                        <img class="emblem" src="{{ asset('assets/panther-badge.png') }}" alt="" aria-hidden="true">
                        <img class="car" src="{{ asset('assets/panther-car.webp') }}" alt="" aria-hidden="true">
                    </div>
                </div>
            </section>

            <section class="section" id="alur">
                <div class="wrap">
                    <h2 class="section-title">Alur pendaftaran anggota</h2>
                    <p class="section-note">Tiga langkah, semuanya dari aplikasi Android.</p>

                    <div class="cards">
                        <article class="card">
                            <span class="step" aria-hidden="true">1</span>
                            <h3>Kirim pengajuan</h3>
                            <p>Isi data diri dan unggah KTP, SIM, serta bukti pembayaran.</p>
                        </article>

                        <article class="card">
                            <span class="step" aria-hidden="true">2</span>
                            <h3>Verifikasi admin</h3>
                            <p>Admin meninjau dokumen sebelum keanggotaan diaktifkan.</p>
                        </article>

                        <article class="card">
                            <span class="step" aria-hidden="true">3</span>
                            <h3>Nomor anggota</h3>
                            <p>Anggota yang disetujui menerima nomor anggota resmi (PM-XXXXXXXX).</p>
                        </article>
                    </div>
                </div>
            </section>
        </main>

        <footer class="site-footer">
            <div class="wrap footer-inner">
                <span>&copy; {{ date('Y') }} {{ config('app.name', 'PantherAPP') }}</span>
                <a href="{{ route('admin.login') }}">Masuk Admin</a>
            </div>
        </footer>
    </body>
</html>
