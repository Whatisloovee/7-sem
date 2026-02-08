import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/favorite.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String products = 'products';
  static const String favorites = 'favorites';

  // Продукты
  Stream<List<Product>> getProductsStream() {
    return _db.collection(products).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> addProduct(Product product) async {
    await _db.collection(products).add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection(products).doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection(products).doc(id).delete();
  }

  // Избранное
  Stream<List<Favorite>> getFavoritesStream(String userId) {
    return _db
        .collection(favorites)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Favorite.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<String> addToFavorites(String userId, String productId) async {
    final doc = await _db.collection(favorites).add({
      'userId': userId,
      'productId': productId,
    });
    return doc.id;
  }

  Future<void> removeFromFavorites(String favoriteId) async {
    await _db.collection(favorites).doc(favoriteId).delete();
  }

  // Дефолтные товары (один раз)
  Future<void> seedDefaultProducts() async {
    final snapshot = await _db.collection(products).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final defaultProducts = [
      Product(id: '', name: 'Aloe Vera', price: 60, image: 'https://cdn.pixabay.com/photo/2018/06/07/11/40/aloe-vera-3459800_1280.jpg'),
      Product(id: '', name: 'Bonsai Tree', price: 120, image: 'https://cdn.pixabay.com/photo/2016/06/07/01/59/bonsai-1441221_1280.jpg'),
      Product(id: '', name: 'Cactus', price: 45, image: 'https://cdn.pixabay.com/photo/2017/04/13/21/28/cactus-2228302_1280.jpg'),
      Product(id: '', name: 'Monstera', price: 95, image: 'https://cdn.pixabay.com/photo/2020/05/22/17/53/monstera-5207281_1280.jpg'),
    ];

    for (final p in defaultProducts) {
      await _db.collection(products).add(p.toMap());
    }
  }
}

final firestoreService = FirestoreService();