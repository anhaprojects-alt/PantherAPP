import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/tugas_model.dart';
import '../../domain/repositories/akademis_repository.dart';

abstract class AkademisEvent {}
class GetTugasRequested extends AkademisEvent {}

abstract class AkademisState {}
class AkademisInitial extends AkademisState {}
class AkademisLoading extends AkademisState {}
class AkademisLoaded extends AkademisState {
  final List<TugasModel> tugasList;
  AkademisLoaded(this.tugasList);
}
class AkademisError extends AkademisState {
  final String message;
  AkademisError(this.message);
}

class AkademisBloc extends Bloc<AkademisEvent, AkademisState> {
  final AkademisRepository repository;

  AkademisBloc({required this.repository}) : super(AkademisInitial()) {
    on<GetTugasRequested>((event, emit) async {
      emit(AkademisLoading());
      try {
        final list = await repository.getTugas();
        emit(AkademisLoaded(list));
      } catch (e) {
        emit(AkademisError(e.toString()));
      }
    });
  }
}
