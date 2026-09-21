import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/akademis/data/datasources/akademis_remote_data_source.dart';
import 'features/akademis/data/repositories/akademis_repository_impl.dart';
import 'features/akademis/domain/repositories/akademis_repository.dart';
import 'features/akademis/presentation/bloc/akademis_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));

  // Features - Akademis
  sl.registerFactory(() => AkademisBloc(repository: sl()));
  sl.registerLazySingleton<AkademisRepository>(() => AkademisRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => AkademisRemoteDataSource(sl()));

  // Core
  sl.registerLazySingleton(() => ApiClient());
}
