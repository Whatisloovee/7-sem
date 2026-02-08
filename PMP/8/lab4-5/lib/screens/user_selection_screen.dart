import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../services/hive_service.dart';
import 'discover_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор пользователя')),
      body: FutureBuilder(
        future: _initializeUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final users = HiveService.getUsers();
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.role),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscoverScreen(currentUser: user),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _initializeUsers() async {
    if (HiveService.getUsers().isEmpty) {
      await compute(_addTestUsers, null);
    }
  }

  static Future<void> _addTestUsers(dynamic _) async {
    await HiveService.addUser(User(id: '1', name: 'Админ', role: 'admin'));
    await HiveService.addUser(User(id: '2', name: 'Менеджер', role: 'manager'));
    await HiveService.addUser(User(id: '3', name: 'Пользователь', role: 'user'));
  }
}