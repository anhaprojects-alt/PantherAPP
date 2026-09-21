import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../domain/repositories/member_repository.dart';

abstract class MemberEvent {}

class LoadProfile extends MemberEvent {}

class SaveProfile extends MemberEvent {
  final Map<String, dynamic> fields;
  SaveProfile(this.fields);
}

class SetAvatar extends MemberEvent {
  final String filePath;
  SetAvatar(this.filePath);
}

class ViewDocument extends MemberEvent {
  final String type;
  ViewDocument(this.type);
}

abstract class MemberState {}

class MemberInitial extends MemberState {}

class MemberLoading extends MemberState {}

class MemberLoaded extends MemberState {
  final UserModel user;
  MemberLoaded(this.user);
}

class DocumentLoaded extends MemberState {
  final String type;
  final Uint8List bytes;
  DocumentLoaded(this.type, this.bytes);
}

class MemberUnauthenticated extends MemberState {}

class MemberError extends MemberState {
  final String message;
  MemberError(this.message);
}

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final MemberRepository repository;

  MemberBloc({required this.repository}) : super(MemberInitial()) {
    on<LoadProfile>(_run(() => repository.fetchProfile()));
    on<SaveProfile>((event, emit) => _run(() => repository.updateProfile(event.fields))(event, emit));
    on<SetAvatar>((event, emit) => _run(() => repository.uploadAvatar(event.filePath))(event, emit));

    on<ViewDocument>((event, emit) async {
      emit(MemberLoading());
      try {
        final bytes = await repository.downloadDocument(event.type);
        emit(DocumentLoaded(event.type, bytes));
      } on UnauthorizedException {
        emit(MemberUnauthenticated());
      } catch (e) {
        emit(MemberError(_clean(e)));
      }
    });
  }

  /// Menjalankan aksi yang mengembalikan [UserModel] dan memancarkan state.
  EventHandler<MemberEvent, MemberState> _run(Future<UserModel> Function() action) {
    return (event, emit) async {
      emit(MemberLoading());
      try {
        emit(MemberLoaded(await action()));
      } on UnauthorizedException {
        emit(MemberUnauthenticated());
      } catch (e) {
        emit(MemberError(_clean(e)));
      }
    };
  }

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '');
}
