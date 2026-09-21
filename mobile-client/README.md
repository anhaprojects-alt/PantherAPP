# Portal Sekolah - Mobile Client

Aplikasi mobile portal sekolah profesional yang dibangun menggunakan **Flutter** dengan arsitektur **Clean Architecture** dan manajemen state **BLoC**. Aplikasi ini terintegrasi dengan backend **Laravel** yang dihosting di Railway.

## Fitur Utama
- 🔐 **Autentikasi**: Login siswa/admin dengan JWT/Sanctum.
- 📊 **Dashboard**: Menu utama dengan navigasi cepat.
- 📚 **Akademis**: Pengelolaan tugas, presensi, dan nilai.

## Teknologi
- **Frontend**: Flutter (BLoC, Dio, GetIt, Secure Storage)
- **Backend**: Laravel (Sanctum)
- **Deployment**: GitHub & Railway

## Cara Setup
1. Pastikan Flutter SDK terinstal.
2. Jalankan `flutter pub get`.
3. Jalankan `flutter run`.
4. Sesuaikan `baseUrl` di `lib/core/network/api_endpoints.dart` dengan URL Railway Anda.

---
Dikembangkan oleh [atifnaufal](https://github.com/atifnaufal)
