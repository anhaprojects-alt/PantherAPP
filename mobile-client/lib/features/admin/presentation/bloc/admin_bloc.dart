import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/models/admin_member.dart';
import '../../domain/repositories/admin_repository.dart';

abstract class AdminEvent {}

class LoadPending extends AdminEvent {}

class LoadDetail extends AdminEvent {
  final int id;
  LoadDetail(this.id);
}

class ApproveMember extends AdminEvent {
  final int id;
  ApproveMember(this.id);
}

class RejectMember extends AdminEvent {
  final int id;
  final String reason;
  RejectMember(this.id, this.reason);
}

class ViewMemberDocument extends AdminEvent {
  final int id;
  final String type;
  ViewMemberDocument(this.id, this.type);
}

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminListLoaded extends AdminState {
  final List<AdminApplicant> items;
  AdminListLoaded(this.items);
}

class AdminDetailLoaded extends AdminState {
  final AdminMember member;
  AdminDetailLoaded(this.member);
}

class AdminDocumentLoaded extends AdminState {
  final Uint8List bytes;
  AdminDocumentLoaded(this.bytes);
}

class AdminUnauthenticated extends AdminState {}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<LoadPending>((event, emit) async {
      emit(AdminLoading());
      try {
        emit(AdminListLoaded(await repository.pending()));
      } on UnauthorizedException {
        emit(AdminUnauthenticated());
      } catch (e) {
        emit(AdminError(_clean(e)));
      }
    });

    on<LoadDetail>((event, emit) => _detail(() => repository.show(event.id)));
    on<ApproveMember>((event, emit) => _detail(() => repository.approve(event.id)));
    on<RejectMember>(
      (event, emit) => _detail(() => repository.reject(event.id, event.reason)),
    );

    on<ViewMemberDocument>((event, emit) async {
      emit(AdminLoading());
      try {
        emit(AdminDocumentLoaded(await repository.document(event.id, event.type)));
      } on UnauthorizedException {
        emit(AdminUnauthenticated());
      } catch (e) {
        emit(AdminError(_clean(e)));
      }
    });
  }

  EventHandler<AdminEvent, AdminState> _detail(Future<AdminMember> Function() action) {
    return (event, emit) async {
      emit(AdminLoading());
      try {
        emit(AdminDetailLoaded(await action()));
      } on UnauthorizedException {
        emit(AdminUnauthenticated());
      } catch (e) {
        emit(AdminError(_clean(e)));
      }
    };
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');
}
