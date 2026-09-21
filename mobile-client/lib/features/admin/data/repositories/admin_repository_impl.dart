import 'dart:typed_data';

import '../../data/datasources/admin_remote_data_source.dart';
import '../../domain/models/admin_member.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AdminApplicant>> pending() => remoteDataSource.pending();

  @override
  Future<AdminMember> show(int id) => remoteDataSource.show(id);

  @override
  Future<AdminMember> approve(int id) => remoteDataSource.approve(id);

  @override
  Future<AdminMember> reject(int id, String reason) =>
      remoteDataSource.reject(id, reason);

  @override
  Future<Uint8List> document(int id, String type) =>
      remoteDataSource.document(id, type);
}
