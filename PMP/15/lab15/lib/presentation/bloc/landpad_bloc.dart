// presentation/bloc/landpad_bloc.dart
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/landpad.dart';
import '../../data/repositories/landpad_repository.dart';

part 'landpad_event.dart';
part 'landpad_state.dart';

class LandpadBloc extends Bloc<LandpadEvent, LandpadState> {
  final LandpadRepository repository;

  LandpadBloc(this.repository) : super(LandpadInitial()) {
    on<LoadLandpads>(_onLoadLandpads);
  }

  Future<void> _onLoadLandpads(
      LoadLandpads event, Emitter<LandpadState> emit) async {
    emit(LandpadLoading());
    try {
      final landpads = await repository.getLandpads();
      emit(LandpadLoaded(landpads));
    } on DioException catch (e) {
      emit(LandpadError(e.message ?? "Ошибка сети"));
    } catch (e) {
      emit(LandpadError("Неизвестная ошибка"));
    }
  }
}