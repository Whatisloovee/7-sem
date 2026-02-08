import 'dart:async';
import 'package:lab4_5/services/firestore_service.dart';
import 'package:lab4_5/models/product.dart';
import 'package:lab4_5/models/favorite.dart';

class FakeFirestoreService implements FirestoreService {
  final List<Product> _products = [];
  final List<Favorite> _favorites = [];
  final StreamController<List<Product>> _productController = StreamController<List<Product>>.broadcast();
  final StreamController<List<Favorite>> _favoriteController = StreamController<List<Favorite>>.broadcast();

  @override
  Stream<List<Product>> getProductsStream() {
    Future.microtask(() => _productController.add(List.from(_products)));
    return _productController.stream;
  }

  @override
  Future<void> addProduct(Product product) async {
    _products.add(product);
    _productController.add(List.from(_products));
  }

  @override
  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      _productController.add(List.from(_products));
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    _productController.add(List.from(_products));
  }

  @override
  Future<void> seedDefaultProducts() async {
    // Добавляем тестовые продукты
    _products.addAll([
      Product(
        id: '1',
        name: 'Тестовое растение 1',
        price: 29.99,
        image: 'https://example.com/plant1.jpg',
      ),
      Product(
        id: '2',
        name: 'Тестовое растение 2',
        price: 39.99,
        image: 'https://example.com/plant2.jpg',
      ),
    ]);
    _productController.add(List.from(_products));
  }

  @override
  Stream<List<Favorite>> getFavoritesStream(String userId) {
    final userFavorites = _favorites.where((fav) => fav.userId == userId).toList();
    Future.microtask(() => _favoriteController.add(userFavorites));
    return _favoriteController.stream;
  }

  @override
  Future<String> addToFavorites(String userId, String productId) async {
    final favorite = Favorite(
      id: 'fav_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      productId: productId,
    );
    _favorites.add(favorite);
    _favoriteController.add(List.from(_favorites));
    return favorite.id;
  }

  @override
  Future<void> removeFromFavorites(String favoriteId) async {
    _favorites.removeWhere((fav) => fav.id == favoriteId);
    _favoriteController.add(List.from(_favorites));
  }

  void dispose() {
    _productController.close();
    _favoriteController.close();
  }
}