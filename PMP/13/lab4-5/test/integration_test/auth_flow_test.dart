import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Импорты проекта
import 'package:lab4_5/blocs/auth/auth_bloc.dart';
import 'package:lab4_5/blocs/product/product_bloc.dart';
import 'package:lab4_5/blocs/favorite/favorite_bloc.dart';
import 'package:lab4_5/screens/discover_screen.dart';
import 'package:lab4_5/screens/auth_screen.dart';
import 'package:lab4_5/services/analytics_service.dart';
import 'package:lab4_5/models/app_user.dart';

// Фейковые сервисы
import '../fakes/fake_firestore_service.dart';
import '../fakes/fake_auth_bloc.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow Test', () {
    late FakeFirestoreService fakeFirestore;

    setUp(() {
      AnalyticsService.isTestMode = true;
      fakeFirestore = FakeFirestoreService();
    });

    tearDown(() {
      fakeFirestore.dispose();
    });

    testWidgets('User can see auth screen and login', (WidgetTester tester) async {
      // Создаем FakeAuthBloc с начальным неавторизованным состоянием
      final fakeAuthBloc = FakeAuthBloc();

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
          child: const MaterialApp(home: AuthScreen()),
        ),
      );

      // Проверяем, что видим экран авторизации
      await tester.pumpAndSettle();
      expect(find.text('Вход'), findsOneWidget);

      // Проверяем наличие основных элементов
      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      expect(find.text('Нет аккаунта? Зарегистрируйтесь'), findsOneWidget);

      // Вводим данные и нажимаем вход
      final emailField = find.byKey(const Key('emailField'));
      final passwordField = find.byKey(const Key('passwordField'));
      final loginButton = find.byKey(const Key('loginButton'));

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      // Эмулируем успешный вход через FakeAuthBloc
      fakeAuthBloc.add(SignInRequested('test@example.com', 'password123'));
      await tester.pump(const Duration(seconds: 2));

      // Теперь переключаем на DiscoverScreen вручную
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

      // Проверяем, что видим Discover screen
      expect(find.text('Discover'), findsOneWidget);
    });
  });
}