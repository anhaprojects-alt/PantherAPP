/// Dilempar saat server menolak token (HTTP 401) agar blok bisa logout paksa.
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Sesi berakhir, silakan login kembali.']);

  @override
  String toString() => message;
}
