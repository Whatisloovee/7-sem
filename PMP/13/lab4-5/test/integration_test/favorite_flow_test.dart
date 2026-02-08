import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Импорты проекта
import 'package:lab4_5/blocs/auth/auth_bloc.dart';
import 'package:lab4_5/blocs/product/product_bloc.dart';
import 'package:lab4_5/blocs/favorite/favorite_bloc.dart';
import 'package:lab4_5/screens/discover_screen.dart';
import 'package:lab4_5/services/analytics_service.dart';
import 'package:lab4_5/models/app_user.dart';

// Фейковые сервисы
import '../fakes/fake_firestore_service.dart';
import '../fakes/fake_auth_bloc.dart';
import '../fakes/fake_online_status_service.dart' as fake_online;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Favorite Flow Test', () {
    late FakeFirestoreService fakeFirestore;

    setUp(() {
      AnalyticsService.isTestMode = true;
      fakeFirestore = FakeFirestoreService();
    });

    tearDown(() {
      fakeFirestore.dispose();
    });

    testWidgets('User can see products on Discover screen', (WidgetTester tester) async {
      // Создаем авторизованного пользователя
      final testUser = AppUser(
        id: 'test_user_1',
        email: 'test@example.com',
        name: 'Test User',
        role: 'user',
      );

      final fakeAuthBloc = FakeAuthBloc(initialUser: testUser);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: fakeAuthBloc),
            BlocProvider<ProductBloc>(
              create: (context) => ProductBloc(firestoreService: fakeFirestore)
                ..add(LoadProducts()),
            ),
            BlocProvider<FavoriteBloc>(
              create: (context) => FavoriteBloc(firestoreService: fakeFirestore),
            ),
          ],
          child: const MaterialApp(home: DiscoverScreen()),
        ),
      );

      // Ждем загрузки - ИСПРАВЛЕНО: используем pump с таймаутом вместо pumpAndSettle
      await tester.pump(const Duration(seconds: 2));

      // Проверяем, что товары отображаются
      expect(find.text('Тестовое растение 1'), findsOneWidget);
      expect(find.text('Тестовое растение 2'), findsOneWidget);

      // Проверяем, что Discover screen загружен
      expect(find.text('Discover'), findsOneWidget);
    });

    testWidgets('User can tap on favorite buttons', (WidgetTester tester) async {
      final testUser = AppUser(
        id: 'test_user_1',
        email: 'test@example.com',
        name: 'Test User',
        role: 'user',
      );

      final fakeAuthBloc = FakeAuthBloc(initialUser: testUser);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: fakeAuthBloc),
            BlocProvider<ProductBloc>(
              create: (context) => ProductBloc(firestoreService: fakeFirestore)
                ..add(LoadProducts()),
            ),
            BlocProvider<FavoriteBloc>(
              create: (context) => FavoriteBloc(firestoreService: fakeFirestore),
            ),
          ],
          child: const MaterialApp(home: DiscoverScreen()),
        ),
      );

      await tester.pump(const Duration(seconds: 2));

      // Находим кнопку избранного и нажимаем ее
      final favoriteButton = find.byKey(const Key('favorite_button_1'));

      // Проверяем, что кнопка существует
      expect(favoriteButton, findsOneWidget);

      // Нажимаем кнопку
      await tester.tap(favoriteButton);
      await tester.pump(const Duration(seconds: 1));

      // Проверяем, что не произошло ошибок и товар все еще виден
      expect(find.text('Тестовое растение 1'), findsOneWidget);
    });
  });
}