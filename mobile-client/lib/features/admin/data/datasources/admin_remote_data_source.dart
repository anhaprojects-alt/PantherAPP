import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/models/admin_member.dart';

class AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSource(this.apiClient);

  Future<List<AdminApplicant>> pending() async {
    final response = await _guard(
      () => apiClient.dio.get(ApiEndpoints.pendingMembers),
    );
    final body = Map<String, dynamic>.from(response.data as Map);
    final data = (body['data'] as List?) ?? const [];
    return data
        .map((e) => AdminApplicant.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<AdminMember> show(int id) async {
    final response = await _guard(
      () => apiClient.dio.get(ApiEndpoints.memberDetail(id)),
    );
    return AdminMember.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<AdminMember> approve(int id) async {
    final response = await _guard(
      () => apiClient.dio.post(ApiEndpoints.approve(id)),
    );
    return AdminMember.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<AdminMember> reject(int id, String reason) async {
    final response = await _guard(
      () => apiClient.dio.post(ApiEndpoints.reject(id), data: {'reason': reason}),
    );
    return AdminMember.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<Uint8List> document(int id, String type) async {
    final response = await _guard(
      () => apiClient.dio.get<List<int>>(
        ApiEndpoints.memberDocument(id, type),
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
