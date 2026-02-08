import 'package:lab4_5/models/app_user.dart';
import 'package:lab4_5/services/auth_service.dart';

class FakeAuthService implements AuthService {
  AppUser? _currentUser;

  @override
  Future<AppUser?> signInWithGoogle() async {
    _currentUser = AppUser(
      id: 'google_user_1',
      email: 'google@example.com',
      name: 'Google User',
      role: 'user',
    );
    return _currentUser;
  }

  @override
  Stream<AppUser?> get userStream {
    return Stream.value(_currentUser);
  }

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    _currentUser = AppUser(
      id: 'test_user_1',
      email: email,
      name: 'Test User',
      role: 'user',
    );
    return _currentUser!;
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword(String email, String password, String name) async {
    _currentUser = AppUser(
      id: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: 'user',
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<AppUser?> getUserData(String uid) async {
    return _currentUser ?? AppUser(
      id: uid,
      email: 'test@example.com',
      name: 'Test User',
      role: 'user',
    );
  }

  @override
  Future<void> createDefaultUsers() async {
    // Ничего не делаем в тестах
  }
}