// lib/blocs/auth/auth_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab4_5/services/analytics_service.dart';
import 'package:lab4_5/services/online_status_service.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    // Подписываемся на поток авторизации из AuthService, если он есть.
    // Если в вашем AuthService нет authStateChanges, замените на:
    // FirebaseAuth.instance.authStateChanges()
    final authStream = FirebaseAuth.instance.authStateChanges();

    _authSubscription = authStream.listen((firebaseUser) {
      if (firebaseUser == null) {
        add(const UserLoggedOut());
      } else {
        add(UserChanged(firebaseUser));
      }
    });

    // === ОБРАБОТКА СОБЫТИЙ ===
    on<AppStarted>(_onAppStarted);
    on<UserChanged>(_onUserChanged);

    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<SignOutRequested>(_onSignOut);
    on<UserLoggedOut>((_, emit) => emit(AuthUnauthenticated()));
    on<PasswordResetRequested>(_onPasswordReset);
  }

  // При старте приложения
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      add(UserChanged(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // Единая точка загрузки пользователя (для email и Google)
  Future<void> _onUserChanged(UserChanged event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    AppUser? appUser;
    // Увеличил число попыток — иногда документ пользователя создаётся с небольшой задержкой после OAuth
    const int maxAttempts = 20;
    for (int i = 0; i < maxAttempts; i++) {
      appUser = await _authService.getUserData(event.firebaseUser.uid);
      if (appUser != null) break;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (appUser != null) {
      try {
        // Устанавливаем онлайн-статус (один вызов достаточно)
        await OnlineStatusService.setOnline();

        // Определяем метод входа
        final provider = event.firebaseUser.providerData
            .map((info) => info.providerId)
            .firstWhere((id) => id != 'firebase', orElse: () => 'password');

        final String method = provider == 'google.com' ? 'google' : 'email';
        await AnalyticsService.logSignIn(method: method);

        emit(AuthAuthenticated(appUser));
      } catch (e) {
        emit(AuthError('Ошибка при установке статуса/логировании: ${e.toString()}'));
        emit(AuthUnauthenticated());
      }
    } else {
      emit(const AuthError('Не удалось загрузить данные пользователя'));
      emit(AuthUnauthenticated());
    }
  }

  // Email/Password вход
  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    // Защита от повторных запросов
    if (state is AuthLoading) return;

    emit(AuthLoading());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );
      // После успешного signIn мы ожидаем событие из authStateChanges -> UserChanged
      // Но если у вас медленно создаётся документ пользователя, _onUserChanged теперь
      // делает более долгие попытки чтения.
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // Регистрация
  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    if (state is AuthLoading) return;

    emit(AuthLoading());
    try {
      await _authService.signUpWithEmailAndPassword(event.email, event.password, event.name);
      // Стрим authStateChanges должен сработать и вызвать UserChanged, который загрузит документ
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapError(e.code)));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // Вход через Google
  Future<void> _onGoogleSignIn(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    if (state is AuthLoading) return;

    emit(AuthLoading());
    try {
      // Предполагается, что signInWithGoogle возвращает AppUser? (или null при отмене)
      final AppUser? appUser = await _authService.signInWithGoogle();
      if (appUser == null) {
        // Пользователь отменил вход
        emit(const AuthError('Вход через Google отменён'));
        emit(AuthUnauthenticated());
        return;
      }

      // Если сервис вернул AppUser — можем сразу эмитить AuthAuthenticated,
      // чтобы UI не зависел только от внешнего authStateChanges (устранение гонки)
      await OnlineStatusService.setOnline();
      await AnalyticsService.logSignIn(method: 'google');
      emit(AuthAuthenticated(appUser));
      // Всё хорошо — поток authStateChanges всё равно продолжит работать в фоне.
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // Выход
  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    if (state is AuthLoading) return;
    emit(AuthLoading());
    try {
      await OnlineStatusService.setOffline();
      await FirebaseAuth.instance.signOut();
      // Явно обновляем состояние — чтобы UI сразу вернулся к экрану логина
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Не удалось выйти: ${e.toString()}'));
      emit(AuthUnauthenticated());
    }
  }

  // Сброс пароля
  Future<void> _onPasswordReset(PasswordResetRequested event, Emitter<AuthState> emit) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: event.email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(const AuthError('Не удалось отправить письмо для сброса пароля'));
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
        return 'Неверный email или пароль';
      case 'email-already-in-use':
        return 'Email уже занят';
      case 'weak-password':
        return 'Слабый пароль';
      case 'invalid-credential':
        return 'Неверные данные для входа';
      default:
        return 'Ошибка: $code';
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}