// providers/user_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/hive_service.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  List<User> _users = [];

  User? get currentUser => _currentUser;
  List<User> get users => _users;

  Future<void> initializeUsers() async {
    if (_users.isEmpty) {
      await _addDefaultUsers();
    }
    _users = HiveService.getUsers();
    notifyListeners();
  }

  Future<void> _addDefaultUsers() async {
    await HiveService.addUser(User(id: '1', name: 'Админ', role: 'admin'));
    await HiveService.addUser(User(id: '2', name: 'Менеджер', role: 'manager'));
    await HiveService.addUser(User(id: '3', name: 'Пользователь', role: 'user'));
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}