import 'package:flutter_test/flutter_test.dart';
import 'package:panther_mania/features/auth/domain/models/user_model.dart';

void main() {
  test('UserModel mem-parse resource member bersarang', () {
    final user = UserModel.fromJson(const {
      'id': 7,
      'name': 'Budi',
      'email': 'budi@panther.test',
      'is_admin': false,
      'member': {
        'id': 3,
        'member_id': 'PM-ABCD1234',
        'status': 'approved',
        'status_label': 'Disetujui',
        'phone': '0812',
      },
    });

    expect(user.isAdmin, isFalse);
    expect(user.member, isNotNull);
    expect(user.member!.isApproved, isTrue);
    expect(user.member!.memberId, 'PM-ABCD1234');
  });

  test('UserModel menolerensi member null', () {
    final user = UserModel.fromJson(const {
      'id': 1,
      'name': 'Admin',
      'email': 'admin@panther.test',
      'is_admin': true,
    });

    expect(user.isAdmin, isTrue);
    expect(user.member, isNull);
  });
}
