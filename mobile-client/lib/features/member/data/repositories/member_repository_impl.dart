import 'dart:typed_data';

import '../../../auth/domain/models/user_model.dart';
import '../../data/datasources/member_remote_data_source.dart';
import '../../domain/repositories/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource remoteDataSource;

  MemberRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserModel> fetchProfile() => remoteDataSource.fetchProfile();

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> fields) =>
      remoteDataSource.updateProfile(fields);

  @override
  Future<UserModel> uploadAvatar(String filePath) =>
      remoteDataSource.uploadAvatar(filePath);

  @override
  Future<Uint8List> downloadDocument(String type) =>
      remoteDataSource.downloadDocument(type);
}
