// lib/services/notification_service.dart

import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      print('🟡 Initializing Notification Service...');

      // ✅ НАСТРОЙКА ИНИЦИАЛИЗАЦИИ С ОБРАБОТКОЙ ОШИБОК
      const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

      // ✅ ИНИЦИАЛИЗАЦИЯ С CALLBACK ДЛЯ ОШИБОК
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Обработка нажатия на уведомление
          print('Notification tapped: ${response.payload}');
        },
        onDidReceiveBackgroundNotificationResponse: _backgroundNotificationHandler,
      );

      // ✅ ЗАПРОС РАЗРЕШЕНИЙ С ОБРАБОТКОЙ ОШИБОК
      try {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false, // для iOS
        );

        print('🔔 Notification permissions: ${settings.authorizationStatus}');
      } catch (e) {
        print('🔴 Error requesting notification permissions: $e');
      }

      // ✅ СОЗДАНИЕ КАНАЛА УВЕДОМЛЕНИЙ
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Важные уведомления',
        description: 'Канал для важных уведомлений магазина растений',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
        print('🟢 Notification channel created');
      }

      // ✅ ОБРАБОТКА СООБЩЕНИЙ НА ПЕРЕДНЕМ ПЛАНЕ С try-catch
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('📱 Foreground message received: ${message.messageId}');

        try {
          await _showNotification(message);
        } catch (e) {
          print('🔴 Error showing notification: $e');
        }
      });

      // ✅ ОБРАБОТКА СООБЩЕНИЙ ПРИ ЗАКРЫТОМ ПРИЛОЖЕНИИ
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📱 Notification opened app: ${message.messageId}');
        _handleNotificationClick(message);
      });

      // ✅ ПОЛУЧЕНИЕ СООБЩЕНИЯ ПРИ ЗАПУСКЕ (если приложение было закрыто)
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print('📱 Initial message: ${initialMessage.messageId}');
        _handleNotificationClick(initialMessage);
      }

      print('🟢 Notification Service initialized successfully');

    } catch (e) {
      print('🔴 Error initializing Notification Service: $e');
    }
  }

  // ✅ МЕТОД ДЛЯ ПОКАЗА УВЕДОМЛЕНИЯ С ПРОВЕРКАМИ
  static Future<void> _showNotification(RemoteMessage message) async {
    try {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification == null) {
        print('🟡 Notification is null, using data payload');
        // Попробуем создать уведомление из data payload
        if (message.data.isNotEmpty) {
          await _notifications.show(
            DateTime.now().millisecondsSinceEpoch.remainder(100000),
            message.data['title'] ?? 'Новое уведомление',
            message.data['body'] ?? 'У вас новое сообщение',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'Важные уведомления',
                channelDescription: 'Канал для важных уведомлений магазина растений',
                icon: '@mipmap/ic_launcher',
                priority: Priority.high,
                importance: Importance.max,
                enableVibration: true,
                playSound: true,
              ),
            ),
          );
        }
        return;
      }

      // ✅ ПРОВЕРЯЕМ ВСЕ ОБЯЗАТЕЛЬНЫЕ ПОЛЯ
      if (notification.title == null || notification.body == null) {
        print('🟡 Notification title or body is null');
        return;
      }

      // ✅ СОЗДАЕМ УВЕДОМЛЕНИЕ
      await _notifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Важные уведомления',
            channelDescription: 'Канал для важных уведомлений магазина растений',
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            priority: Priority.high,
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
            color: Color(0xFF4CAF50),
          ),
        ),
        payload: message.data.toString(),
      );

      print('🟢 Notification shown: ${notification.title}');

    } catch (e) {
      print('🔴 Error in _showNotification: $e');
    }
  }

  // ✅ ОБРАБОТЧИК ДЛЯ ФОНОВЫХ УВЕДОМЛЕНИЙ
  @pragma('vm:entry-point')
  static void _backgroundNotificationHandler(NotificationResponse response) {
    print('Background notification handler: ${response.payload}');
    // Обработка уведомлений в фоне
  }

  // ✅ ОБРАБОТКА НАЖАТИЯ НА УВЕДОМЛЕНИЕ
  static void _handleNotificationClick(RemoteMessage message) {
    print('Notification clicked: ${message.data}');

    // Здесь можно добавить навигацию на конкретный экран
    // Например: Navigator.push(context, MaterialPageRoute(...))
  }

  // ✅ ПОЛУЧЕНИЕ ТОКЕНА С ОБРАБОТКОЙ ОШИБОК
  static Future<String?> getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print('🔑 FCM Token: $token');
      return token;
    } catch (e) {
      print('🔴 Error getting FCM token: $e');
      return null;
    }
  }

  // ✅ МЕТОД ДЛЯ ПОКАЗА ТЕСТОВОГО УВЕДОМЛЕНИЯ
  static Future<void> showTestNotification() async {
    try {
      await _notifications.show(
        123456,
        'Тестовое уведомление',
        'Это тестовое уведомление из приложения',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Важные уведомления',
            channelDescription: 'Канал для важных уведомлений магазина растений',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
      print('🟢 Test notification shown');
    } catch (e) {
      print('🔴 Error showing test notification: $e');
    }
  }
}