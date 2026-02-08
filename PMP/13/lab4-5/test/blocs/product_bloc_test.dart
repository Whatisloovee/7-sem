import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:lab4_5/blocs/product/product_bloc.dart';
import 'package:lab4_5/models/product.dart';
import '../mocks.mocks.dart';  // Generated mocks

@GenerateMocks([])  // If needed for additional mocks
void main() {
  group('ProductBloc', () {
    late MockFirestoreService mockFirestoreService;
    late StreamController<List<Product>> streamController;

    setUp(() {
      mockFirestoreService = MockFirestoreService();
      streamController = StreamController<List<Product>>();
    });

    tearDown(() {
      streamController.close();
    });

    // Test 1: Happy path for loading products (emits loading, sets up stream, emits loaded)
    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when LoadProducts is added and stream emits data',
      build: () {
        // Mock seedDefaultProducts to succeed (async void)
        when(mockFirestoreService.seedDefaultProducts()).thenAnswer((_) async {});
        // Mock the stream to return a controllable stream
        when(mockFirestoreService.getProductsStream()).thenAnswer((_) => streamController.stream);
        return ProductBloc(firestoreService: mockFirestoreService);
      },
      act: (bloc) async {
        bloc.add(LoadProducts());
        // Simulate Firestore stream emitting data after event
        streamController.add([Product(id: '1', name: 'Test Product', price: 10, image: 'url')]);
      },
      expect: () => [
        ProductLoading(),
        ProductLoaded([Product(id: '1', name: 'Test Product', price: 10, image: 'url')]),
      ],
      verify: (_) {
        // Verify mocks were called
        verify(mockFirestoreService.seedDefaultProducts()).called(1);
        verify(mockFirestoreService.getProductsStream()).called(1);
      },
    );

    // Test 2: Adding a product (calls service, no state change since update via stream)
    blocTest<ProductBloc, ProductState>(
      'calls addProduct on FirestoreService when AddProduct is added',
      build: () {
        // Mock addProduct to succeed
        when(mockFirestoreService.addProduct(any)).thenAnswer((_) async {});
        return ProductBloc(firestoreService: mockFirestoreService);
      },
      act: (bloc) => bloc.add(AddProduct(Product(id: '2', name: 'New Product', price: 20, image: 'url'))),
      expect: () => [],  // No direct state emission; update comes via stream
      verify: (_) {
        verify(mockFirestoreService.addProduct(argThat(isA<Product>()))).called(1);
      },
    );

    // Test 3: Error handling for updating a product
    blocTest<ProductBloc, ProductState>(
      'emits ProductError when UpdateProduct fails',
      build: () {
        // Mock updateProduct to throw an error
        when(mockFirestoreService.updateProduct(any)).thenThrow(Exception('Update failed'));
        return ProductBloc(firestoreService: mockFirestoreService);
      },
      act: (bloc) => bloc.add(UpdateProduct(Product(id: '3', name: 'Updated Product', price: 30, image: 'url'))),
      expect: () => [ProductError('Ошибка обновления: Exception: Update failed')],
    );
  });
}