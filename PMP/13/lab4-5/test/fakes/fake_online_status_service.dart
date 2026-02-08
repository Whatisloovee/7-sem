class FakeOnlineStatusService {
  static Future<void> setOnline() async {
    // Ничего не делаем в тестах
  }

  static Future<void> setOffline() async {
    // Ничего не делаем в тестах
  }

  static Future<void> updateLastSeen() async {
    // Ничего не делаем в тестах
  }

  static Stream<Map<String, dynamic>?> getStatusStream(String userId) {
    // Возвращаем онлайн статус для тестов
    return Stream.value({
      'online': true,
      'lastSeen': DateTime.now(),
    });
  }
}