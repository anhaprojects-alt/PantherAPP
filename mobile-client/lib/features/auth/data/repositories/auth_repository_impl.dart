import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    final token = response['token'];
    final user = UserModel.fromJson(response['user']);
    
    await storage.write(key: 'auth_token', value: token);
    return user;
  }

  @override
  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
  }
}
