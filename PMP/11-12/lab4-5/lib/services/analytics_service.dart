// lib/services/analytics_service.dart

import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Включить сбор аналитики в debug-режиме (по желанию)
  static Future<void> init() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  // Универсальный метод логирования события
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // === Конкретные события приложения ===

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