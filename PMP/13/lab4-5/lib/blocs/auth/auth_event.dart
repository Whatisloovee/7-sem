part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const SignUpRequested(this.email, this.password, this.name);
  @override
  List<Object?> get props => [email, password, name];
}

// ← НОВОЕ
class GoogleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested(this.email);
}

// ← НОВОЕ (для стрима)
class UserChanged extends AuthEvent {
  final User firebaseUser;
  const UserChanged(this.firebaseUser);
  @override
  List<Object?> get props => [firebaseUser];
}

class UserLoggedOut extends AuthEvent {
  const UserLoggedOut();
}

