part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class InitializeUsers extends UserEvent {}

class SelectUser extends UserEvent {
  final User user;
  const SelectUser(this.user);
  @override
  List<Object?> get props => [user];
}

class LogoutUser extends UserEvent {}