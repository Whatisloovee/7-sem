// landpad_event.dart
part of 'landpad_bloc.dart';

abstract class LandpadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLandpads extends LandpadEvent {}