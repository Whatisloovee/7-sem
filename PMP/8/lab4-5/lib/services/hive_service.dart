import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/favorite.dart';

class HiveService {
  static late Box<User> userBox;
  static late Box<Product> productBox;
  static late Box<Favorite> favoriteBox;
  static late encrypt.Encrypter encrypter;
  static late encrypt.Key key;
  static late encrypt.Key wrongKey;

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(directory.path);

    // Регистрация адаптеров
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(FavoriteAdapter());

    // Генерация ИЛИ загрузка ключа
    key = await _getOrCreateEncryptionKey();
    wrongKey = encrypt.Key.fromSecureRandom(32);
    encrypter = encrypt.Encrypter(encrypt.AES(key));

    // ОБНОВЛЕНО: Открытие боксов с шифрованием и стратегией сжатия
    userBox = await Hive.openBox<User>(
      'users',
      encryptionCipher: HiveAesCipher(key.bytes),
      compactionStrategy: (totalEntries, deletedEntries) {
        // Сжимать если удалено более 20% записей
        return deletedEntries > totalEntries * 0.2;
      },
    );

    productBox = await Hive.openBox<Product>(
      'products',
      encryptionCipher: HiveAesCipher(key.bytes),
      compactionStrategy: (totalEntries, deletedEntries) {
        return deletedEntries > totalEntries * 0.2;
      },
    );

    favoriteBox = await Hive.openBox<Favorite>(
      'favorites',
      encryptionCipher: HiveAesCipher(key.bytes),
      compactionStrategy: (totalEntries, deletedEntries) {
        return deletedEntries > totalEntries * 0.2;
      },
    );
  }

  // Получить существующий ключ или создать новый
  static Future<encrypt.Key> _getOrCreateEncryptionKey() async {
    final directory = await getApplicationDocumentsDirectory();
    final keyFile = File('${directory.path}/hive_encryption_key.key');

    try {
      if (await keyFile.exists()) {
        final keyBytes = await keyFile.readAsBytes();
        print('Ключ загружен из: ${keyFile.path}');
        return encrypt.Key(keyBytes);
      } else {
        final newKey = encrypt.Key.fromSecureRandom(32);
        await keyFile.writeAsBytes(newKey.bytes);
        print('Новый ключ создан и сохранен в: ${keyFile.path}');
        return newKey;
      }
    } catch (e) {
      print('Ошибка работы с ключом: $e');
      return encrypt.Key.fromSecureRandom(32);
    }
  }


  // Демонстрация ручного сжатия
  static Future<void> demonstrateManualCompaction() async {
    print('=== ДЕМОНСТРАЦИЯ РУЧНОГО СЖАТИЯ ===');

    // Создаем тестовый бокс
    var testBox = await Hive.openBox<String>(
      'compaction_demo',
      compactionStrategy: (total, deleted) => false, // Отключаем авто-сжатие
    );

    // Сохраняем начальный размер
    final initialSize = await _getBoxSize('compaction_demo');
    print('Начальный размер бокса: $initialSize байт');

    // Добавляем много данных
    for (int i = 0; i < 100; i++) {
      await testBox.put('key_$i', 'Данные для сжатия номер $i ' * 10);
    }

    final afterAddSize = await _getBoxSize('compaction_demo');
    print('Размер после добавления 100 записей: $afterAddSize байт');

    // Удаляем половину данных (создаем "дыры")
    for (int i = 0; i < 50; i++) {
      await testBox.delete('key_$i');
    }

    final afterDeleteSize = await _getBoxSize('compaction_demo');
    print('Размер после удаления 50 записей: $afterDeleteSize байт');
    print('(Данные все еще занимают место из-за "дыр")');

    // ВЫПОЛНЯЕМ РУЧНОЕ СЖАТИЕ
    print('--- ВЫПОЛНЯЕМ box.compact() ---');
    await testBox.compact();

    final afterCompactSize = await _getBoxSize('compaction_demo');
    print('Размер после сжатия: $afterCompactSize байт');

    // Считаем эффективность сжатия
    final efficiency = ((afterDeleteSize - afterCompactSize) / afterDeleteSize * 100);
    print('Эффективность сжатия: ${efficiency.toStringAsFixed(1)}%');

    // Проверяем, что данные остались доступны
    final remainingData = testBox.get('key_99');
    print('Данные после сжатия: ${remainingData?.substring(0, 30)}...');

    await testBox.close();
    await Hive.deleteBoxFromDisk('compaction_demo');
    print('=== ДЕМОНСТРАЦИЯ ЗАВЕРШЕНА ===\n');
  }

  // Демонстрация автоматического сжатия
  static Future<void> demonstrateAutoCompaction() async {
    print('=== ДЕМОНСТРАЦИЯ АВТОМАТИЧЕСКОГО СЖАТИЯ ===');

    var autoBox = await Hive.openBox<String>(
      'auto_compaction_demo',
      compactionStrategy: (totalEntries, deletedEntries) {
        // АВТО-СЖАТИЕ: срабатывает когда удалено больше 30% записей
        bool shouldCompact = deletedEntries > totalEntries * 0.3;
        if (shouldCompact) {
          print('Авто-сжатие активировано! Удалено: $deletedEntries из $totalEntries');
        }
        return shouldCompact;
      },
    );

    // Добавляем данные
    for (int i = 0; i < 50; i++) {
      await autoBox.put('auto_key_$i', 'Авто-сжатие данные $i');
    }

    // Постепенно удаляем данные до порога срабатывания
    for (int i = 0; i < 20; i++) { // 40% удаления > 30% порога
      await autoBox.delete('auto_key_$i');
      print('Удалена запись auto_key_$i');
    }

    // Hive автоматически вызовет compact() при следующей операции
    await autoBox.put('trigger', 'Эта операция вызовет авто-сжатие');

    final finalSize = await _getBoxSize('auto_compaction_demo');
    print('Финальный размер после авто-сжатия: $finalSize байт');

    await autoBox.close();
    await Hive.deleteBoxFromDisk('auto_compaction_demo');
    print('=== АВТО-СЖАТИЕ ЗАВЕРШЕНО ===\n');
  }

  // Вспомогательный метод для получения размера бокса
  static Future<int> _getBoxSize(String boxName) async {
    final directory = await getApplicationDocumentsDirectory();
    final boxFile = File('${directory.path}/$boxName.hive');
    if (await boxFile.exists()) {
      return await boxFile.length();
    }
    return 0;
  }

  // Метод для принудительного сжатия всех боксов
  static Future<void> compactAllBoxes() async {
    print('=== ПРИНУДИТЕЛЬНОЕ СЖАТИЕ ВСЕХ БОКСОВ ===');

    final boxes = [userBox, productBox, favoriteBox];
    final boxNames = ['users', 'products', 'favorites'];

    for (int i = 0; i < boxes.length; i++) {
      final initialSize = await _getBoxSize(boxNames[i]);
      await boxes[i].compact();
      final finalSize = await _getBoxSize(boxNames[i]);

      print('${boxNames[i]}: ${initialSize} → ${finalSize} байт '
          '(${initialSize - finalSize} байт сэкономлено)');
    }
    print('=== СЖАТИЕ ЗАВЕРШЕНО ===\n');
  }

  // Показать информацию о ключе
  static Future<void> showKeyInfo() async {
    final directory = await getApplicationDocumentsDirectory();
    final keyFile = File('${directory.path}/hive_encryption_key.key');

    if (await keyFile.exists()) {
      final keyBytes = await keyFile.readAsBytes();
      print('Путь к ключу: ${keyFile.path}');
      print('Размер ключа: ${keyBytes.length} байт');
    } else {
      print('Файл ключа не существует');
    }
  }

  // Удалить ключ (для тестирования)
  static Future<void> deleteKey() async {
    final directory = await getApplicationDocumentsDirectory();
    final keyFile = File('${directory.path}/hive_encryption_key.key');

    if (await keyFile.exists()) {
      await keyFile.delete();
      print('🗑️ Ключ удален: ${keyFile.path}');
    }
  }

  // Методы для работы с пользователями
  static Future<void> addUser(User user) async {
    await userBox.put(user.id, user);
  }

  static List<User> getUsers() => userBox.values.toList();

  // Методы для работы с товарами
  static Future<void> addProduct(Product product) async {
    await productBox.put(product.id, product);
  }

  static Future<void> updateProduct(Product product) async {
    await addProduct(product);
  }

  static Future<void> deleteProduct(String id) async {
    await productBox.delete(id);
  }

  static List<Product> getProducts() => productBox.values.toList();

  // Методы для работы с избранным
  static Future<void> addFavorite(Favorite favorite) async {
    await favoriteBox.put(favorite.id, favorite);
  }

  static Future<void> deleteFavorite(String id) async {
    await favoriteBox.delete(id);
  }

  static List<Favorite> getFavorites(String userId) =>
      favoriteBox.values.where((f) => f.userId == userId).toList();

  // Демонстрация чтения с неправильным ключом
  static Future<void> tryWrongKey() async {
    const boxName = 'testBox';

    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName);

    Box<String>? testBox;
    Box<String>? wrongBox;

    try {
      print('Создание бокса с правильным ключом...');
      testBox = await Hive.openBox<String>(
        boxName,
        encryptionCipher: HiveAesCipher(key.bytes),
      );
      const testData = 'Test Data';
      await testBox.put('testKey', testData);
      print('Данные успешно записаны с правильным ключом: ${testBox.get('testKey')}');
      await testBox.close();

      print('Попытка открыть бокс с неправильным ключом...');
      wrongBox = await Hive.openBox<String>(
        boxName,
        encryptionCipher: HiveAesCipher(wrongKey.bytes),
      );
      final data = wrongBox.get('testKey');
      if (data == null) {
        print('Данные недоступны с неправильным ключом (ожидаемое поведение).');
        throw HiveError('Failed to decrypt data with wrong key.');
      }
    } catch (e) {
      print('Ошибка при использовании неправильного ключа: $e');
    } finally {
      if (testBox != null && testBox.isOpen) await testBox.close();
      if (wrongBox != null && wrongBox.isOpen) await wrongBox.close();
      await Hive.deleteBoxFromDisk(boxName);
    }
  }
}