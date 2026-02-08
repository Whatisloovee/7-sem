// landpad_state.dart

part of 'landpad_bloc.dart';


abstract class LandpadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LandpadInitial extends LandpadState {}
class LandpadLoading extends LandpadState {}
class LandpadLoaded extends LandpadState {
  final List<Landpad> landpads;
  LandpadLoaded(this.landpads);
}
class LandpadError extends LandpadState {
  final String message;
  LandpadError(this.message);
}