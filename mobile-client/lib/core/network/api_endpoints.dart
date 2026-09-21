class ApiEndpoints {
  // Diturunkan ke mode Production agar terhubung langsung dengan backend Railway Anda
  static const bool isProduction = true;
  static const String prodBaseUrl = 'https://pantherapp-production.up.railway.app/api';
  static const String devBaseUrl = 'http://127.0.0.1:8000/api';

  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // Auth (Diselaraskan dengan endpoint Laravel Sanctum pada PantherAPP)
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String userProfile = '/me';
  static const String updateProfile = '/me/profile';

  // Admin Review (Untuk kelengkapan administrasi seluler)
  static const String pendingMembers = '/admin/members/pending';

  // Academic
  static const String tugas = '/tugas';
  static const String presensi = '/presensi';
  static const String nilai = '/nilai';
}
