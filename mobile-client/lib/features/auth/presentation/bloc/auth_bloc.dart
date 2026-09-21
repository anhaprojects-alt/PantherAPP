import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/registration_data.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final RegistrationData data;
  RegisterRequested(this.data);
}

class LogoutRequested extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class RegisterSubmitted extends AuthState {
  final String message;
  RegisterSubmitted(this.message);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.login(event.email, event.password);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(_clean(e)));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final message = await authRepository.register(event.data);
        emit(RegisterSubmitted(message));
      } catch (e) {
        emit(AuthError(_clean(e)));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await authRepository.logout();
      emit(AuthInitial());
    });
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');
}
