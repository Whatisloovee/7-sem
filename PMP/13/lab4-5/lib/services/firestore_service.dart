import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/favorite.dart';

class FirestoreService {
  final FirebaseFirestore? _db;

  FirestoreService({FirebaseFirestore? firestore}) : _db = firestore;

  // Мок-данные для тестов
  final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Aloe Vera',
      price: 60.0,
      image: 'https://via.placeholder.com/150?text=Aloe+Vera',
    ),
    Product(
      id: '2',
      name: 'Bonsai Tree',
      price: 120.0,
      image: 'https://via.placeholder.com/150?text=Bonsai+Tree',
    ),
    Product(
      id: '3',
      name: 'Cactus',
      price: 45.0,
      image: 'https://via.placeholder.com/150?text=Cactus',
    ),
  ];

  final List<Favorite> _mockFavorites = [];

  // Продукты
  Stream<List<Product>> getProductsStream() {
    if (_db == null) {
      // Возвращаем мок-данные
      return Stream.value(_mockProducts);
    }

    return _db!.collection('products').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> addProduct(Product product) async {
    if (_db == null) {
      // Добавляем в мок-данные
      _mockProducts.add(product);
      return;
    }

    await _db!.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    if (_db == null) {
      // Обновляем в мок-данных
      final index = _mockProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _mockProducts[index] = product;
      }
      return;
    }

    await _db!.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    if (_db == null) {
      // Удаляем из мок-данных
      _mockProducts.removeWhere((p) => p.id == id);
      return;
    }

    await _db!.collection('products').doc(id).delete();
  }

  // Избранное
  Stream<List<Favorite>> getFavoritesStream(String userId) {
    if (_db == null) {
      // Возвращаем мок-данные
      return Stream.value(_mockFavorites.where((f) => f.userId == userId).toList());
    }

    return _db!
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Favorite.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<String> addToFavorites(String userId, String productId) async {
    if (_db == null) {
      // Добавляем в мок-данные
      final favorite = Favorite(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        productId: productId,
      );
      _mockFavorites.add(favorite);
      return favorite.id;
    }

    final doc = await _db!.collection('favorites').add({
      'userId': userId,
      'productId': productId,
    });
    return doc.id;
  }

  Future<void> removeFromFavorites(String favoriteId) async {
    if (_db == null) {
      // Удаляем из мок-данных
      _mockFavorites.removeWhere((f) => f.id == favoriteId);
      return;
    }

    await _db!.collection('favorites').doc(favoriteId).delete();
  }

  Future<void> seedDefaultProducts() async {
    if (_db == null) {
      // Уже есть мок-данные
      return;
    }

    final snapshot = await _db!.collection('products').limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final defaultProducts = [
      Product(id: '', name: 'Aloe Vera', price: 60, image: 'https://...'),
      Product(id: '', name: 'Bonsai Tree', price: 120, image: 'https://...'),
      Product(id: '', name: 'Cactus', price: 45, image: 'https://...'),
      Product(id: '', name: 'Monstera', price: 95, image: 'https://...'),
    ];

    for (final p in defaultProducts) {
      await _db!.collection('products').add(p.toMap());
    }
  }
}