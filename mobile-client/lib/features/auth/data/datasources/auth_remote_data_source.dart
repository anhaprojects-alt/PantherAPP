import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/registration_data.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw Exception(_message(e, 'Login gagal'));
    }
  }

  /// Mendaftar sebagai calon member dengan mengunggah dokumen identitas.
  Future<String> register(RegistrationData data) async {
    try {
      final formData = FormData.fromMap({
        'name': data.name,
        'email': data.email,
        'password': data.password,
        'password_confirmation': data.password,
        'phone': data.phone,
        'ktp_number': data.ktpNumber,
        'sim_number': data.simNumber,
        'ktp': await MultipartFile.fromFile(data.ktpPath, filename: 'ktp.jpg'),
        'sim': await MultipartFile.fromFile(data.simPath, filename: 'sim.jpg'),
        'payment': await MultipartFile.fromFile(data.paymentPath, filename: 'payment.jpg'),
      });

      final response = await apiClient.dio.post(
        ApiEndpoints.register,
        data: formData,
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      return body['message'] as String? ?? 'Pendaftaran berhasil.';
    } on DioException catch (e) {
      throw Exception(_message(e, 'Pendaftaran gagal'));
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post(ApiEndpoints.logout);
    } on DioException catch (_) {
      // Token dicabut lokal apa pun respons server.
    }
  }

  String _message(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}
