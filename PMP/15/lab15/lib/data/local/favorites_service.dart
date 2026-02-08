// data/local/favorites_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/landpad.dart';

class FavoritesService {
  static const String boxName = 'favorites_landpads';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(LandpadAdapter());
    await Hive.openBox<Landpad>(boxName);
  }

  Box<Landpad> get box => Hive.box<Landpad>(boxName);

  Future<void> toggleFavorite(Landpad landpad) async {
    if (box.containsKey(landpad.id)) {
      await box.delete(landpad.id);
    } else {
      await box.put(landpad.id, landpad);
    }
  }

  bool isFavorite(String id) => box.containsKey(id);

  List<Landpad> getFavorites() => box.values.toList();
}

// Hive Adapter
class LandpadAdapter extends TypeAdapter<Landpad> {
  @override
  final typeId = 0;

  @override
  Landpad read(BinaryReader reader) {
    final map = reader.readMap();
    return Landpad.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  void write(BinaryWriter writer, Landpad obj) {
    writer.writeMap(obj.toJson());
  }
}