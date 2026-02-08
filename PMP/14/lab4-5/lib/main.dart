import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/favorite/favorite_bloc.dart';
import 'screens/user_selection_screen.dart';
import 'services/hive_service.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserBloc()..add(InitializeUsers())),
        BlocProvider(create: (context) => ProductBloc()..add(LoadProducts())),
        BlocProvider(create: (context) => FavoriteBloc()),
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