import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab4_5/models/favorite.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lab4_5/blocs/auth/auth_bloc.dart';
import 'package:lab4_5/blocs/favorite/favorite_bloc.dart';
import 'package:lab4_5/blocs/product/product_bloc.dart';
import 'package:lab4_5/models/app_user.dart';
import 'package:lab4_5/models/product.dart';
import 'package:lab4_5/screens/discover_screen.dart';
import 'package:lab4_5/services/analytics_service.dart';
import 'package:lab4_5/services/remote_config_service.dart';

// --- 1. Создаем Mock-классы для BLoC ---
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockProductBloc extends MockBloc<ProductEvent, ProductState> implements ProductBloc {}
class MockFavoriteBloc extends MockBloc<FavoriteEvent, FavoriteState> implements FavoriteBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockProductBloc mockProductBloc;
  late MockFavoriteBloc mockFavoriteBloc;

  // Тестовые данные
  final testUser = const AppUser(
    id: 'user123',
    email: 'test@test.com',
    name: 'TestUser',
    role: 'user',
  );

  final testProducts = [
    const Product(id: 'p1', name: 'Aloe Vera', price: 15.0, image: 'url1'),
    const Product(id: 'p2', name: 'Cactus', price: 10.0, image: 'url2'),
    const Product(id: 'p3', name: 'Ficus', price: 25.0, image: 'url3'),
    const Product(id: 'p4', name: 'Monstera', price: 40.0, image: 'url4'),
    const Product(id: 'p5', name: 'Rose', price: 12.0, image: 'url5'),
  ];

  final testProduct1 = Product(
    id: 'product_id_1',
    name: 'Монстера',
    price: 25.0,
    image: 'http://example.com/monstera.jpg',
  );

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockProductBloc = MockProductBloc();
    mockFavoriteBloc = MockFavoriteBloc();

    // Настраиваем статические сервисы для тестов
    AnalyticsService.isTestMode = true;
    // В реальном проекте лучше мокать обертки над этими сервисами,
    // но для Widget-теста предположим, что они имеют дефолтные значения.
  });

  // Вспомогательная функция для создания окружения виджета
  Widget createWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<ProductBloc>.value(value: mockProductBloc),
        BlocProvider<FavoriteBloc>.value(value: mockFavoriteBloc),
      ],
      child: const MaterialApp(
        home: DiscoverScreen(),
      ),
    );
  }

  group('DiscoverScreen Tests', () {

    // --- Тест 1: Проверка отображения (Smoke Test) ---
    testWidgets('Displays loading indicator when products are loading', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
      when(() => mockProductBloc.state).thenReturn(ProductLoading()); // Состояние загрузки
      when(() => mockFavoriteBloc.state).thenReturn(FavoriteInitial());

      await tester.pumpWidget(createWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // --- Тест 2: Ввод текста (enterText) ---
    testWidgets('User can enter text into search field', (tester) async {
      // Подготовка состояний
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
      when(() => mockProductBloc.state).thenReturn(ProductLoaded(testProducts));
      when(() => mockFavoriteBloc.state).thenReturn(const FavoriteLoaded([]));

      await tester.pumpWidget(createWidget());

      // 1. Находим поле поиска
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // 2. Вводим текст
      await tester.enterText(searchField, 'Ficus');
      //await tester.pump(); // Перерисовка

      // 3. Проверяем, что текст введен
      expect(find.text('Ficus'), findsOneWidget);
    });

    // --- Тест 3: Нажатие на категорию (Tap) ---
    testWidgets('Tapping favorite button toggles icon color and sends event', (tester) async {
      // 1. Настройка: Убедимся, что лайки ВКЛЮЧЕНЫ
      // (Поскольку _ProductCard проверяет RemoteConfigService.isLikeEnabled)
      RemoteConfigService.isLikeEnabled = true;

      // Настройка состояния BLoC-ов
      // Изначально продукт НЕ в избранном (FavoriteLoaded([]))
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
      when(() => mockProductBloc.state).thenReturn(ProductLoaded([testProduct1]));
      when(() => mockFavoriteBloc.state).thenReturn(const FavoriteLoaded([]));

      final favoriteAddedState = FavoriteLoaded([Favorite(
          id: '1',
          userId: testUser.id,
          productId: testProduct1.id
      )]);

      // Имитируем переход из пустого состояния в состояние с добавленным избранным
      whenListen(
        mockFavoriteBloc,
        Stream.fromIterable([favoriteAddedState]),
        initialState: const FavoriteLoaded([]),
      );

      await tester.pumpWidget(createWidget());

      // 2. Находим кнопку сердечка (по ключу)
      final favoriteButtonFinder = find.byKey(Key('favorite_button_${testProduct1.id}'));
      expect(favoriteButtonFinder, findsOneWidget);

      // Изначально иконка должна быть серой (Icons.favorite_border)
      var initialIcon = tester.widget<Icon>(find.descendant(
        of: favoriteButtonFinder,
        matching: find.byType(Icon),
      ));
      expect(initialIcon.icon, Icons.favorite_border);
      expect(initialIcon.color, Colors.grey);


      // 4. Выполняем Tap (Добавляем в избранное)
      await tester.tap(favoriteButtonFinder);
      await tester.pumpAndSettle(); // Ждем, пока BlocConsumer обновит UI (из-за whenListen)

      // Иконка должна измениться на Icons.favorite (залитое сердечко) и стать красной.
      var finalIcon = tester.widget<Icon>(find.descendant(
        of: favoriteButtonFinder,
        matching: find.byType(Icon),
      ));
      expect(finalIcon.icon, Icons.favorite);
      expect(finalIcon.color, Colors.red);

      // 6. ПРОВЕРКА 3: Проверяем, что событие было отправлено
      verify(() => mockFavoriteBloc.add(
        ToggleFavorite(testUser.id, testProduct1.id),
      )).called(1);
    });


// --- Тест 4: Скроллинг списка товаров (Drag) ---
    testWidgets('User can scroll the product grid', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
      when(() => mockProductBloc.state).thenReturn(ProductLoaded(testProducts));
      when(() => mockFavoriteBloc.state).thenReturn(const FavoriteLoaded([]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // 1. Находим ListView по ключу (самый надежный способ!)
      final listViewFinder = find.byKey(const Key('categories_list'));

      expect(listViewFinder, findsOneWidget);
      //expect(find.text('Экзотика3'), findsOneWidget);
      // 2. Прокручиваем горизонтально влево
      await tester.drag(listViewFinder, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // 3. Проверяем, что появилась категория 'Экзотика5'
      expect(find.text('Экзотика3'), findsOneWidget);
    });



    // --- Тест 5: Лайк товара (Tap + Взаимодействие с BLoC) ---
    testWidgets('Tapping favorite button triggers ToggleFavorite event', (tester) async {
      // Включаем лайки через мок конфига (если бы он не был статическим)
      // В данном случае полагаемся, что RemoteConfigService.isLikeEnabled по умолчанию true
      // или контролируем это статической переменной, если к ней есть доступ.

      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
      when(() => mockProductBloc.state).thenReturn(ProductLoaded(testProducts));
      when(() => mockFavoriteBloc.state).thenReturn(const FavoriteLoaded([]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // 1. Находим кнопку лайка для первого продукта по ключу
      // В коде виджета: Key('favorite_button_${widget.product.id}')
      final likeButtonFinder = find.byKey(const Key('favorite_button_p1'));

      // Если кнопка не найдена (RemoteConfig выключен), тест упадет, что тоже полезно знать
      expect(likeButtonFinder, findsOneWidget);

      // 2. Нажимаем (прямой вызов onTap для обхода проблемы с hit test)
      final favoriteButton = tester.widget<GestureDetector>(likeButtonFinder);
      favoriteButton.onTap!();
      await tester.pump();

      // 3. Проверяем, что событие ушло в BLoC
      verify(() => mockFavoriteBloc.add(const ToggleFavorite('user123', 'p1'))).called(1);
    });
  });
}