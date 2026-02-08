import 'package:flutter/material.dart';

class FakeRemoteConfigService {
  static bool isLikeEnabled = true;
  static Color primaryColor = const Color(0xFF4CAF50);
  static Color accentColor = const Color(0xFFFF5722);

  static Future<void> initialize() async {
    // Ничего не делаем в тестах
  }

  static void addConfigListener(VoidCallback callback) {
    // Ничего не делаем в тестах
  }

  static void removeConfigListener(VoidCallback callback) {
    // Ничего не делаем в тестах
  }

  static Future<void> forceFetch() async {
    // Ничего не делаем в тестах
  }
}