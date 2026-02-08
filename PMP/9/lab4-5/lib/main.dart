// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/hive_service.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/favorite_provider.dart';
import 'screens/user_selection_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
      ],
      child: MaterialApp(
        title: 'Plant Shop',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.green[50],
        ),
        home: const UserSelectionScreen(),
      ),
    );
  }
}