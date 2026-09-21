import 'member_model.dart';

/// Proyeksi `UserResource`: akun beserta profil member terlampir.
class UserModel {
  final int id;
  final String name;
  final String email;
  final bool isAdmin;
  final MemberModel? member;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    this.member,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawMember = json['member'];
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      member: rawMember is Map<String, dynamic>
          ? MemberModel.fromJson(rawMember)
          : null,
    );
  }
}
