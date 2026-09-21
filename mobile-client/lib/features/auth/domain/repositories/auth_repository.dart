import '../models/registration_data.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<String> register(RegistrationData data);
  Future<void> logout();
  Future<bool> hasSession();
}
