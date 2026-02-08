// lib/services/remote_config_service.dart

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Ключи для Remote Config
  static const String _enableLikeButtonKey = 'enable_like_button';
  static const String _primaryColorKey = 'app_primary_color';
  static const String _accentColorKey = 'app_accent_color';

  // Значения по умолчанию
  static bool enableLikeButton = true;
  static Color primaryColor = const Color(0xFF4CAF50);
  static Color accentColor = const Color(0xFFFF5722);

  // ✅ ИСПОЛЬЗУЕМ СПИСОК CALLBACK'ОВ ВМЕСТО ОДНОГО
  static final List<VoidCallback> _configChangedCallbacks = [];

  static Future<void> initialize() async {
    try {
      // Устанавливаем значения по умолчанию
      await _remoteConfig.setDefaults({
        _enableLikeButtonKey: true,
        _primaryColorKey: '#4CAF50',
        _accentColorKey: '#FF5722',
      });

      // Настройки для разработки (частое обновление)
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 10),
      ));

      // Загружаем и активируем конфигурацию
      await _fetchAndActivate();

      // Обновляем локальные переменные
      _updateValues();

      // Слушаем обновления в реальном времени
      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
        _updateValues();
      });

    } catch (e) {
      print('Error initializing Remote Config: $e');
    }
  }

  static Future<void> _fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Error fetching remote config: $e');
    }
  }

  static void _updateValues() {
    // Сохраняем старые значения для сравнения
    final bool oldLikeState = enableLikeButton;

    // Обновляем состояние кнопки лайка
    enableLikeButton = _remoteConfig.getBool(_enableLikeButtonKey);

    // Обновляем цвета
    final primaryHex = _remoteConfig.getString(_primaryColorKey);
    final accentHex = _remoteConfig.getString(_accentColorKey);

    primaryColor = _hexToColor(primaryHex);
    accentColor = _hexToColor(accentHex);

    // ✅ УВЕДОМЛЯЕМ ВСЕХ ЗАРЕГИСТРИРОВАННЫХ СЛУШАТЕЛЕЙ
    if (oldLikeState != enableLikeButton) {
      _notifyConfigChanged();
    }
  }

  // ✅ ДОБАВЛЯЕМ МЕТОДЫ ДЛЯ РАБОТЫ СО СПИСКОМ CALLBACK'ОВ
  static void addConfigListener(VoidCallback callback) {
    _configChangedCallbacks.add(callback);
  }

  static void removeConfigListener(VoidCallback callback) {
    _configChangedCallbacks.remove(callback);
  }

  static void _notifyConfigChanged() {
    for (final callback in _configChangedCallbacks) {
      callback();
    }
  }

  static Color _hexToColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse('0x$hex'));
    } catch (e) {
      print('Error parsing color: $e');
      return const Color(0xFF4CAF50); // fallback color
    }
  }

  // Принудительное обновление
  static Future<void> forceFetch() async {
    await _fetchAndActivate();
    _updateValues();
  }

  // Геттер для проверки доступности лайков
  static bool get isLikeEnabled => enableLikeButton;
}