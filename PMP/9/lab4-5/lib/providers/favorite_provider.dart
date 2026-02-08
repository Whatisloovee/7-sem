// providers/favorite_provider.dart
import 'package:flutter/foundation.dart';
import '../models/favorite.dart';
import '../services/hive_service.dart';

class FavoriteProvider with ChangeNotifier {
  List<Favorite> _favorites = [];

  List<Favorite> get favorites => _favorites;

  void loadFavorites(String userId) {
    _favorites = HiveService.getFavorites(userId);
    notifyListeners();
  }

  Future<void> addFavorite(Favorite favorite) async {
    await HiveService.addFavorite(favorite);
    _favorites = HiveService.getFavorites(favorite.userId);
    notifyListeners();
  }

  Future<void> deleteFavorite(String id, String userId) async {
    await HiveService.deleteFavorite(id);
    _favorites = HiveService.getFavorites(userId);
    notifyListeners();
  }

  bool isProductFavorite(String productId, String userId) {
    return _favorites.any((favorite) =>
    favorite.productId == productId && favorite.userId == userId);
  }

  String getFavoriteId(String productId, String userId) {
    return '${userId}_$productId';
  }
}