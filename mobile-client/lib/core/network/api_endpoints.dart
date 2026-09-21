class ApiEndpoints {
  // Production menunjuk ke backend Railway PantherAPP.
  static const bool isProduction = true;
  static const String prodBaseUrl =
      'https://pantherapp-production.up.railway.app/api';
  // 10.0.2.2 adalah alias host mesin dari dalam Android emulator.
  static const String devBaseUrl = 'http://10.0.2.2:8000/api';

  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // Auth (Laravel Sanctum).
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  // Profil member yang sedang login.
  static const String me = '/me';
  static const String updateProfile = '/me/profile';
  static const String avatar = '/me/avatar';
  static String document(String type) => '/me/documents/$type';

  // Review admin.
  static const String pendingMembers = '/admin/members/pending';
  static String memberDetail(int id) => '/admin/members/$id';
  static String approve(int id) => '/admin/members/$id/approve';
  static String reject(int id) => '/admin/members/$id/reject';
  static String memberDocument(int id, String type) =>
      '/admin/members/$id/documents/$type';
}
