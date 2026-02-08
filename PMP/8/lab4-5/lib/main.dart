import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/hive_service.dart';
import 'screens/discover_screen.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('ИНИЦИАЛИЗАЦИЯ HIVE...');
  await HiveService.init();

  print('\nИНФОРМАЦИЯ О КЛЮЧЕ:');
  await HiveService.showKeyInfo();

  print('\nДЕМОНСТРАЦИЯ НЕПРАВИЛЬНОГО КЛЮЧА:');
  await HiveService.tryWrongKey();

  print('\nДЕМОНСТРАЦИЯ РУЧНОГО СЖАТИЯ:');
  await HiveService.demonstrateManualCompaction();

  print('\nДЕМОНСТРАЦИЯ АВТОМАТИЧЕСКОГО СЖАТИЯ:');
  await HiveService.demonstrateAutoCompaction();

  print('\nПРИНУДИТЕЛЬНОЕ СЖАТИЕ ОСНОВНЫХ БОКСОВ:');
  await HiveService.compactAllBoxes();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Shop',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green[50],
      ),
      home: const UserSelectionScreen(),
    );
  }
}

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор пользователя')),
      body: FutureBuilder(
        future: HiveService.getUsers().isEmpty
            ? Future.wait([
          HiveService.addUser(User(id: '1', name: 'Админ', role: 'admin')),
          HiveService.addUser(User(id: '2', name: 'Менеджер', role: 'manager')),
          HiveService.addUser(User(id: '3', name: 'Пользователь', role: 'user')),
        ])
            : Future.value(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                  Navigator.pushReplacement(
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
}