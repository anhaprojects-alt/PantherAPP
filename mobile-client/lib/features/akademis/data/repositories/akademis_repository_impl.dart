import '../../domain/models/tugas_model.dart';
import '../../domain/repositories/akademis_repository.dart';
import '../datasources/akademis_remote_data_source.dart';

class AkademisRepositoryImpl implements AkademisRepository {
  final AkademisRemoteDataSource remoteDataSource;

  AkademisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TugasModel>> getTugas() async {
    return await remoteDataSource.getTugas();
  }
}
