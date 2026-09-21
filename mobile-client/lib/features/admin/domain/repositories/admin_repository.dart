import 'dart:typed_data';

import '../models/admin_member.dart';

abstract class AdminRepository {
  Future<List<AdminApplicant>> pending();
  Future<AdminMember> show(int id);
  Future<AdminMember> approve(int id);
  Future<AdminMember> reject(int id, String reason);
  Future<Uint8List> document(int id, String type);
}
