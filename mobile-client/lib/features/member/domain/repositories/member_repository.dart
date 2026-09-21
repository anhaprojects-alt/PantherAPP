import 'dart:typed_data';

import '../../../auth/domain/models/user_model.dart';

abstract class MemberRepository {
  Future<UserModel> fetchProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> fields);
  Future<UserModel> uploadAvatar(String filePath);
  Future<Uint8List> downloadDocument(String type);
}
