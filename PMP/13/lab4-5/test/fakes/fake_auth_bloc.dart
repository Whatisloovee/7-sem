import 'package:bloc/bloc.dart';
import 'package:lab4_5/blocs/auth/auth_bloc.dart';
import 'package:lab4_5/models/app_user.dart';

class FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  FakeAuthBloc({AppUser? initialUser}) : super(AuthInitial()) {
    if (initialUser != null) {
      emit(AuthAuthenticated(initialUser));
    }
  }

  @override
  void add(AuthEvent event) {
    if (event is SignInRequested) {
      // Эмулируем успешный вход
      final user = AppUser(
        id: 'test_user_1',
        email: event.email,
        name: 'Test User',
        role: 'user',
      );
      emit(AuthAuthenticated(user));
    } else if (event is SignOutRequested) {
      emit(AuthUnauthenticated());
    }
    // Обрабатываем другие события по необходимости
  }

  @override
  Future<void> close() {
    return super.close();
  }
}