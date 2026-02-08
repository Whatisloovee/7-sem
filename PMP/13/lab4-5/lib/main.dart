// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lab4_5/services/analytics_service.dart';
import 'package:lab4_5/services/notification_service.dart';
import 'package:lab4_5/services/remote_config_service.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/favorite/favorite_bloc.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'screens/auth_screen.dart';
import 'screens/discover_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await NotificationService.initialize();
  await RemoteConfigService.initialize();
// ← ИНИЦИАЛИЗАЦИЯ АНАЛИТИКИ
  await AnalyticsService.init();

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Логируем открытие приложения
  await AnalyticsService.logAppOpen();
  // Получи токен (выведи в консоль — скопируешь для теста)
  String? token = await NotificationService.getToken();
  print('FCM Token: $token');
  // Дефолтные пользователи и товары — создаём один раз (можно убрать потом)
  await authService.createDefaultUsers();
  final firestoreService = FirestoreService();
  await firestoreService.seedDefaultProducts();

  runApp(MyApp(firestoreService: firestoreService));
}

class MyApp extends StatelessWidget {
  final FirestoreService firestoreService;

  const MyApp({super.key, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authService: authService)..add(AppStarted())),
        BlocProvider(
          create: (_) => ProductBloc(firestoreService: firestoreService)..add(LoadProducts()),
        ),
        BlocProvider(
          create: (_) => FavoriteBloc(firestoreService: firestoreService),
        ),
      ],
      child: MaterialApp(
        title: 'Plant Shop',
        theme: ThemeData(primarySwatch: Colors.green),
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            print('Текущее состояние AuthBloc: $state');

            if (state is AuthInitial || state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Просто возвращаем нужный экран без навигации
            if (state is AuthAuthenticated) {
              return const DiscoverScreen();
            }

            return const AuthScreen();
          },
        ),
      ),
    );
  }
}