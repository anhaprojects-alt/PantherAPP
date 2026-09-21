import '../models/tugas_model.dart';

abstract class AkademisRepository {
  Future<List<TugasModel>> getTugas();
}
