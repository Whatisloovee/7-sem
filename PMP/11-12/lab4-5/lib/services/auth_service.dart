import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ← НОВАЯ ФУНКЦИЯ
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Пользователь отменил

      // Получаем токены
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Вход в Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      // Проверяем, есть ли пользователь в Firestore
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        return AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          name: data['name'] ?? firebaseUser.displayName ?? 'User',
          role: data['role'] ?? 'user',
        );
      }

      // Если нет — создаём
      final newUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        name: firebaseUser.displayName ?? 'User',
        role: 'user',
      );
      await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
      return newUser;
    } catch (e) {
      print('Ошибка входа через Google: $e');
      rethrow;
    }
  }
  // Стрим текущего пользователя (с данными из Firestore)
  Stream<AppUser?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          return AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email!,
            name: data['name'] ?? firebaseUser.email!.split('@').first,
            role: data['role'] ?? 'user',
          );
        }

        // Создаем пользователя, если не найден
        final newUser = AppUser.fromFirebaseUser(firebaseUser.uid, firebaseUser.email!);
        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
        return newUser;

      } catch (e) {
        print('Ошибка в userStream: $e');
        return null;
      }
    });
  }

  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      return AppUser(
        id: user.uid,
        email: user.email!,
        name: data['name'] ?? user.email!.split('@').first,
        role: data['role'] ?? 'user',
      );
    }

    final newUser = AppUser.fromFirebaseUser(user.uid, user.email!);
    await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
    return newUser;
  }

  Future<AppUser> signUpWithEmailAndPassword(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;

    final newUser = AppUser(
      id: user.uid,
      email: email,
      name: name.isEmpty ? email.split('@').first : name,
      role: 'user',
    );

    await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
    return newUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> getUserData(String uid) async {
    try {
      print('Загружаем данные пользователя: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      print('Документ существует: ${doc.exists}');
      if (doc.exists) {
        final data = doc.data()!;
        print('Данные пользователя: $data');
        return AppUser(
          id: uid,
          email: data['email'] ?? '',
          name: data['name'] ?? 'Пользователь',
          role: data['role'] ?? 'user',
        );
      }
      print('Пользователь не найден в Firestore!');
      return null;
    } catch (e) {
      print('Ошибка получения данных пользователя: $e');
      return null;
    }
  }
  Future<void> createDefaultUsers() async {
    final defaults = [
      {'email': 'admin@plantshop.com', 'pass': 'admin123', 'name': 'Админ', 'role': 'admin'},
      {'email': 'manager@plantshop.com', 'pass': 'manager123', 'name': 'Менеджер', 'role': 'manager'},
      {'email': 'user@plantshop.com', 'pass': 'user123', 'name': 'Пользователь', 'role': 'user'},
    ];

    for (final u in defaults) {
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(u['email']!);
        if (methods.isEmpty) {
          final cred = await _auth.createUserWithEmailAndPassword(email: u['email']!, password: u['pass']!);
          final appUser = AppUser(id: cred.user!.uid, email: u['email']!, name: u['name']!, role: u['role']!);
          await _firestore.collection('users').doc(cred.user!.uid).set(appUser.toMap());
          print('Создан: ${u['email']}');
        }
      } catch (e) {
        // Игнорируем, если уже существует
      }
    }
  }
}

final authService = AuthService();