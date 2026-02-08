import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart'; // Для debugPrint

class AnalyticsService {
  // 1. Добавляем флаг тестового режима
  static bool isTestMode = false;

  // 2. Делаем доступ к Firebase ленивым (через геттер),
  // чтобы он не вызывался сразу при старте файла
  static FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  static Future<void> init() async {
    // Если тест - выходим
    if (isTestMode) return;
    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  // Универсальный метод логирования события
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    // 3. Главная проверка: если тест, просто пишем в консоль и не трогаем Firebase
    if (isTestMode) {
      debugPrint('[TEST MODE] Analytics event: $name, params: $parameters');
      return;
    }

    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // === Конкретные события приложения (без изменений) ===

  static Future<void> logAppOpen() => logEvent(name: 'app_open');

  static Future<void> logSignIn({required String method}) =>
      logEvent(name: 'login', parameters: {'method': method});

  static Future<void> logSignUp({required String method}) =>
      logEvent(name: 'sign_up', parameters: {'method': method});

  static Future<void> logProductView({required String productId, required String productName}) =>
      logEvent(name: 'view_item', parameters: {
        'item_id': productId,
        'item_name': productName,
      });

  static Future<void> logAddToFavorites({required String productId, required String productName}) =>
      logEvent(name: 'add_to_wishlist', parameters: {
        'item_id': productId,
        'item_name': productName,
      });

  static Future<void> logRemoveFromFavorites({required String productId}) =>
      logEvent(name: 'remove_from_wishlist', parameters: {'item_id': productId});

  static Future<void> logSearch({required String searchTerm}) =>
      logEvent(name: 'search', parameters: {'search_term': searchTerm});

  static Future<void> logAdminProductAdded({required String productName}) =>
      logEvent(name: 'admin_product_added', parameters: {'product_name': productName});

  static Future<void> logAdminProductDeleted({required String productId}) =>
      logEvent(name: 'admin_product_deleted', parameters: {'product_id': productId});
}