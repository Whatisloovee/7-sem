// lib/services/online_status_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class OnlineStatusService {
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Вызывать при входе в приложение и периодически
  static Future<void> setOnline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = _db.child('userStatus').child(user.uid);

    await ref.set({
      'online': true,
      'lastSeen': ServerValue.timestamp,
    });

    // Автоматически ставим offline при отключении (закрытие приложения, потеря сети и т.д.)
    await ref.onDisconnect().update({
      'online': false,
      'lastSeen': ServerValue.timestamp,
    });
  }

  /// Вызывать при выходе из аккаунта (опционально — onDisconnect и так сработает)
  static Future<void> setOffline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.child('userStatus').child(user.uid).update({
      'online': false,
      'lastSeen': ServerValue.timestamp,
    });
  }

  /// Только обновить время активности (если нужно чаще, чем раз в 30 сек)
  static Future<void> updateLastSeen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.child('userStatus').child(user.uid).update({
      'lastSeen': ServerValue.timestamp,
    });
  }

  /// Стрим статуса конкретного пользователя (для ProfileScreen)
  static Stream<Map<String, dynamic>?> getStatusStream(String userId) {
    return _db.child('userStatus').child(userId).onValue.map((event) {
      final data = event.snapshot.value as Map<Object?, Object?>?;
      if (data == null) return null;

      final online = data['online'] as bool? ?? false;
      final timestamp = data['lastSeen'] as int?;

      return {
        'online': online,
        'lastSeen': timestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(timestamp)
            : null,
      };
    });
  }
}