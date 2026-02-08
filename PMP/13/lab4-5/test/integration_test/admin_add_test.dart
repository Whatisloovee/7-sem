import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Импорты вашего проекта
import 'package:lab4_5/screens/admin_screen.dart';
import 'package:lab4_5/blocs/product/product_bloc.dart';
import 'package:lab4_5/models/product.dart';
import 'package:lab4_5/services/analytics_service.dart';

import '../fakes/fake_firestore_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  AnalyticsService.isTestMode = true;

  testWidgets('Admin can add a new product and see it in the list', (WidgetTester tester) async {
    // 2. ПОДГОТОВКА (Arrange)
    final fakeFirestore = FakeFirestoreService();

    Widget testWidget = MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ProductBloc(firestoreService: fakeFirestore)..add(LoadProducts()),
          ),
        ],
        child: const AdminScreen(),
      ),
    );

    // 3. ЗАПУСК UI (Act)
    await tester.pumpWidget(testWidget);

    // Вместо pumpAndSettle в начале можно использовать pump,
    // чтобы избежать зависания, если спиннер крутится вечно (из-за StreamController)
    await tester.pump();

    // ИСПРАВЛЕНИЕ: Не проверяем "Нет товаров", так как FakeFirestoreService уже добавляет тестовые продукты
    // Вместо этого проверяем, что загрузились тестовые продукты
    expect(find.text('Тестовое растение 1'), findsOneWidget);
    expect(find.text('Тестовое растение 2'), findsOneWidget);

    // 4. ВЗАИМОДЕЙСТВИЕ (Interaction)
    final nameFinder = find.byKey(const Key('nameField'));
    final priceFinder = find.byKey(const Key('priceField'));
    final imageFinder = find.byKey(const Key('imageField'));
    final addButtonFinder = find.byKey(const Key('addButton'));

    await tester.enterText(nameFinder, 'Тестовый Кактус');
    await tester.pumpAndSettle();

    await tester.enterText(priceFinder, '150.0');
    await tester.pumpAndSettle();

    await tester.enterText(imageFinder, 'http://example.com/cactus.png');
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // Нажимаем "Добавить"
    await tester.tap(addButtonFinder);
    await tester.pumpAndSettle();

    // 5. ПРОВЕРКА (Assert)
    expect(find.text('Тестовый Кактус'), findsOneWidget);
    expect(find.text('\$150.00'), findsOneWidget);
  });
}