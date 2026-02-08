// providers/product_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/hive_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;

  ProductProvider() {
    _loadProducts();
  }

  void _loadProducts() {
    _products = HiveService.getProducts();
    if (_products.isEmpty) {
      _addDefaultProducts();
    }
  }

  void _addDefaultProducts() {
    addProduct(Product(
      id: '1',
      name: 'Aloe Vera',
      price: 60,
      image: 'https://www.cmp24.ru/images/prodacts/sourse/105628/105628848_aloe-vera-d12-h35-lerua-merlen.jpg',
    ));
    addProduct(Product(
      id: '2',
      name: 'Bonsai',
      price: 60,
      image: 'https://avatars.mds.yandex.net/i?id=367d93fe8bce347503f548aba6cd32b5e40f91e7-12635770-images-thumbs&n=13',
    ));
    notifyListeners();
  }

  void initializeProducts() {
    _products = HiveService.getProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await HiveService.addProduct(product);
    _products = HiveService.getProducts();
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await HiveService.updateProduct(product);
    _products = HiveService.getProducts();
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await HiveService.deleteProduct(id);
    _products = HiveService.getProducts();
    notifyListeners();
  }


  Product? getProductById(String id) {
    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }
}