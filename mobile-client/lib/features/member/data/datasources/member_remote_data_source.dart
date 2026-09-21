import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/domain/models/user_model.dart';

class MemberRemoteDataSource {
  final ApiClient apiClient;

  MemberRemoteDataSource(this.apiClient);

  Future<UserModel> fetchProfile() async {
    final response = await _guard(() => apiClient.dio.get(ApiEndpoints.me));
    return UserModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<UserModel> updateProfile(Map<String, dynamic> fields) async {
    final response = await _guard(
      () => apiClient.dio.put(ApiEndpoints.updateProfile, data: fields),
    );
    return UserModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<UserModel> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
    });
    final response = await _guard(
      () => apiClient.dio.post(ApiEndpoints.avatar, data: formData),
    );
    return UserModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<Uint8List> downloadDocument(String type) async {
    final response = await _guard(
      () => apiClient.dio.get<List<int>>(
        ApiEndpoints.document(type),
        options: Options(responseType: ResponseType.bytes),
      ),
    );
    return Uint8List.fromList(response.data ?? const <int>[]);
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        throw Exception(data['message'] as String);
      }
      rethrow;
    }
  }
}
