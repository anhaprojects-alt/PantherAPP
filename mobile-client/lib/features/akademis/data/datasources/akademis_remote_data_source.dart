import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/tugas_model.dart';

class AkademisRemoteDataSource {
  final ApiClient apiClient;

  AkademisRemoteDataSource(this.apiClient);

  Future<List<TugasModel>> getTugas() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.tugas);
      return (response.data as List)
          .map((item) => TugasModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch tugas');
    }
  }
}
