import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'features/admin/data/datasources/admin_remote_data_source.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/member/data/datasources/member_remote_data_source.dart';
import 'features/member/data/repositories/member_repository_impl.dart';
import 'features/member/domain/repositories/member_repository.dart';
import 'features/member/presentation/bloc/member_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient());

  // Feature - Auth
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));

  // Feature - Member
  sl.registerFactory(() => MemberBloc(repository: sl()));
  sl.registerLazySingleton<MemberRepository>(
    () => MemberRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => MemberRemoteDataSource(sl()));

  // Feature - Admin
  sl.registerFactory(() => AdminBloc(repository: sl()));
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => AdminRemoteDataSource(sl()));
}
