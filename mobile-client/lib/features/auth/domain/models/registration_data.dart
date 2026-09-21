/// Berkas + isian formulir pendaftaran member baru.
///
/// Path gambar dipegang sebagai `String?` agar lapisan domain tidak bergantung
/// pada `dart:io` maupun plugin `image_picker`.
class RegistrationData {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String ktpNumber;
  final String simNumber;
  final String ktpPath;
  final String simPath;
  final String paymentPath;

  const RegistrationData({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.ktpNumber,
    required this.simNumber,
    required this.ktpPath,
    required this.simPath,
    required this.paymentPath,
  });
}
