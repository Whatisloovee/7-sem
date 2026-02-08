import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'vehicle.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'vehicles.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vehicles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            model TEXT,
            year INTEGER,
            speed REAL,
            type TEXT,
            doors INTEGER,
            hasSidecar INTEGER,
            cargoCapacity REAL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    await db.insert('vehicles', vehicle.toMap());
  }

  Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final maps = await db.query('vehicles');
    return maps.map((map) => Vehicle.fromMap(map)).toList();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<void> deleteVehicle(int id) async {
    final db = await database;
    await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }
}