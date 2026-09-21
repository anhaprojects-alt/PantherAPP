import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/registration_data.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String tokenKey = 'auth_token';

  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage storage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    this.storage = const FlutterSecureStorage(),
  });

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    await storage.write(key: tokenKey, value: response['token'] as String?);
    return UserModel.fromJson(
      Map<String, dynamic>.from(response['user'] as Map),
    );
  }

  @override
  Future<String> register(RegistrationData data) =>
      remoteDataSource.register(data);

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await storage.delete(key: tokenKey);
  }

  @override
  Future<bool> hasSession() async {
    final token = await storage.read(key: tokenKey);
    return token != null && token.isNotEmpty;
  }
}
