import 'dart:convert';
import 'dart:async';

// Интерфейс
abstract interface class Transportable {
  void move();
  void stop();
  String getInfo();
}

// Mixins для иерархии классов
mixin Acceleratable on Vehicle {
  void accelerate([double amount = 10.0]) {
    speed += amount;
  }
}

mixin Repairable on Vehicle {
  void repair({bool urgent = false, double cost = 100.0}) {
    print('Repairing $model, urgent: $urgent, cost: $cost');
  }
}

mixin Stoppable on Vehicle {
  @override
  void stop() {
    speed = 0;
  }
}

mixin Movable on Vehicle {
  @override
  void move() {
    print('Moving $model at speed $speed km/h');
  }
}

// Абстрактный класс с реализацией Comparable
abstract class Vehicle implements Transportable, Comparable<Vehicle> {
  static int totalVehicles = 0;

  String _model;
  int _year;
  double _speed;

  Vehicle(this._model, this._year, this._speed) {
    totalVehicles++;
  }

  // Getter и Setter
  String get model => _model;
  set model(String value) => _model = value;

  int get year => _year;
  set year(int value) => _year = value;

  double get speed => _speed;
  set speed(double value) => _speed = value;

  // Статический метод
  static String getTotalVehiclesString() {
    return 'Total vehicles created: $totalVehicles';
  }

  // Метод с параметром типа функция
  void performMaintenance(void Function(String) callback) {
    callback('Maintenance performed on $_model');
  }

  @override
  String getInfo() {
    return 'Model: $_model, Year: $_year, Speed: $_speed km/h';
  }

  // Реализация Comparable (сравнение по году выпуска)
  @override
  int compareTo(Vehicle other) {
    return _year.compareTo(other._year);
  }

  // Асинхронный метод
  Future<void> startEngine() async {
    await Future.delayed(Duration(seconds: 1));
    print('Engine of $_model started');
  }

  // Single subscription stream
  Stream<double> speedStream() async* {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(seconds: 1));
      yield _speed + i * 10;
    }
  }
}

// Класс для демонстрации Iterable и Iterator
class VehicleFleet implements Iterable<Vehicle> {
  final List<Vehicle> _vehicles = [];

  void add(Vehicle vehicle) {
    _vehicles.add(vehicle);
  }

  void remove(Vehicle vehicle) {
    _vehicles.remove(vehicle);
  }

  @override
  Iterator<Vehicle> get iterator => _VehicleIterator(_vehicles);

  @override
  bool get isEmpty => _vehicles.isEmpty;

  @override
  bool get isNotEmpty => _vehicles.isNotEmpty;

  @override
  int get length => _vehicles.length;

  @override
  Vehicle get first {
    if (_vehicles.isEmpty) throw StateError('No elements');
    return _vehicles.first;
  }

  @override
  Vehicle get last {
    if (_vehicles.isEmpty) throw StateError('No elements');
    return _vehicles.last;
  }

  @override
  Vehicle get single {
    if (_vehicles.isEmpty) throw StateError('No elements');
    if (_vehicles.length > 1) throw StateError('More than one element');
    return _vehicles.single;
  }

  @override
  Vehicle elementAt(int index) {
    return _vehicles.elementAt(index);
  }

  @override
  bool any(bool Function(Vehicle) test) {
    for (var vehicle in _vehicles) {
      if (test(vehicle)) return true;
    }
    return false;
  }

  @override
  Iterable<Vehicle> where(bool Function(Vehicle) test) {
    var result = <Vehicle>[];
    for (var vehicle in _vehicles) {
      if (test(vehicle)) result.add(vehicle);
    }
    return result;
  }

  @override
  Iterable<T> whereType<T>() {
    var result = <T>[];
    for (var vehicle in _vehicles) {
      if (vehicle is T) result.add(vehicle as T);
    }
    return result;
  }

  @override
  Iterable<T> map<T>(T Function(Vehicle) f) {
    var result = <T>[];
    for (var vehicle in _vehicles) {
      result.add(f(vehicle));
    }
    return result;
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(Vehicle) f) {
    var result = <T>[];
    for (var vehicle in _vehicles) {
      result.addAll(f(vehicle));
    }
    return result;
  }

  @override
  Vehicle firstWhere(bool Function(Vehicle) test, {Vehicle Function()? orElse}) {
    for (var vehicle in _vehicles) {
      if (test(vehicle)) return vehicle;
    }
    if (orElse != null) return orElse();
    throw StateError('No element satisfying test');
  }

  @override
  Vehicle lastWhere(bool Function(Vehicle) test, {Vehicle Function()? orElse}) {
    for (int i = _vehicles.length - 1; i >= 0; i--) {
      if (test(_vehicles[i])) return _vehicles[i];
    }
    if (orElse != null) return orElse();
    throw StateError('No element satisfying test');
  }

  @override
  Vehicle singleWhere(bool Function(Vehicle) test, {Vehicle Function()? orElse}) {
    Vehicle? result;
    bool found = false;
    for (var vehicle in _vehicles) {
      if (test(vehicle)) {
        if (found) throw StateError('More than one element satisfying test');
        result = vehicle;
        found = true;
      }
    }
    if (found) return result!;
    if (orElse != null) return orElse();
    throw StateError('No element satisfying test');
  }

  @override
  bool contains(Object? element) {
    return _vehicles.contains(element);
  }

  @override
  void forEach(void Function(Vehicle) action) {
    for (var vehicle in _vehicles) {
      action(vehicle);
    }
  }

  @override
  Iterable<Vehicle> take(int count) {
    var result = <Vehicle>[];
    for (int i = 0; i < count && i < _vehicles.length; i++) {
      result.add(_vehicles[i]);
    }
    return result;
  }

  @override
  Iterable<Vehicle> takeWhile(bool Function(Vehicle) test) {
    var result = <Vehicle>[];
    for (var vehicle in _vehicles) {
      if (!test(vehicle)) break;
      result.add(vehicle);
    }
    return result;
  }

  @override
  Iterable<Vehicle> skip(int count) {
    var result = <Vehicle>[];
    for (int i = count; i < _vehicles.length; i++) {
      result.add(_vehicles[i]);
    }
    return result;
  }

  @override
  Iterable<Vehicle> skipWhile(bool Function(Vehicle) test) {
    var result = <Vehicle>[];
    bool skipping = true;
    for (var vehicle in _vehicles) {
      if (skipping && test(vehicle)) continue;
      skipping = false;
      result.add(vehicle);
    }
    return result;
  }

  @override
  Vehicle reduce(Vehicle Function(Vehicle, Vehicle) combine) {
    if (_vehicles.isEmpty) throw StateError('No elements');
    Vehicle value = _vehicles.first;
    for (int i = 1; i < _vehicles.length; i++) {
      value = combine(value, _vehicles[i]);
    }
    return value;
  }

  @override
  T fold<T>(T initialValue, T Function(T, Vehicle) combine) {
    T value = initialValue;
    for (var vehicle in _vehicles) {
      value = combine(value, vehicle);
    }
    return value;
  }

  @override
  bool every(bool Function(Vehicle) test) {
    for (var vehicle in _vehicles) {
      if (!test(vehicle)) return false;
    }
    return true;
  }

  @override
  String join([String separator = ""]) {
    if (_vehicles.isEmpty) return "";
    String result = _vehicles.first.toString();
    for (int i = 1; i < _vehicles.length; i++) {
      result += separator + _vehicles[i].toString();
    }
    return result;
  }

  @override
  List<Vehicle> toList({bool growable = true}) {
    return List<Vehicle>.from(_vehicles, growable: growable);
  }

  @override
  Set<Vehicle> toSet() {
    return Set<Vehicle>.from(_vehicles);
  }

  @override
  Iterable<Vehicle> get reversed {
    var result = <Vehicle>[];
    for (int i = _vehicles.length - 1; i >= 0; i--) {
      result.add(_vehicles[i]);
    }
    return result;
  }

  @override
  Iterable<Vehicle> followedBy(Iterable<Vehicle> other) {
    var result = <Vehicle>[];
    result.addAll(_vehicles);
    result.addAll(other);
    return result;
  }

  @override
  Iterable<R> cast<R>() {
    var result = <R>[];
    for (var vehicle in _vehicles) {
      result.add(vehicle as R);
    }
    return result;
  }

  @override
  String toString() => 'VehicleFleet(${_vehicles.length} vehicles)';
}

class _VehicleIterator implements Iterator<Vehicle> {
  final List<Vehicle> _vehicles;
  int _index = -1;

  _VehicleIterator(this._vehicles);

  @override
  Vehicle get current {
    if (_index < 0 || _index >= _vehicles.length) {
      throw StateError('Iterator not initialized or out of bounds');
    }
    return _vehicles[_index];
  }

  @override
  bool moveNext() {
    _index++;
    return _index < _vehicles.length;
  }
}

// Конкретные классы с mixins
class Car extends Vehicle with Acceleratable, Repairable, Stoppable, Movable {
  int _doors;

  Car(String model, int year, double speed, this._doors) : super(model, year, speed);

  // Именованный конструктор
  Car.basic() : this('Toyota Basic', 2020, 0, 2);

  int get doors => _doors;
  set doors(int value) => _doors = value;

  void openDoors([int doorNumber = 1]) {
    print('Opening door $doorNumber on $model');
  }

  // Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'year': year,
      'speed': speed,
      'doors': doors,
    };
  }
}

class Motorcycle extends Vehicle with Acceleratable, Repairable, Stoppable, Movable {
  bool _hasSidecar;

  Motorcycle(String model, int year, double speed, this._hasSidecar)
      : super(model, year, speed);

  // Именованный конструктор
  Motorcycle.basic() : this('Basic Motorcycle', 2019, 0, false);

  bool get hasSidecar => _hasSidecar;
  set hasSidecar(bool value) => _hasSidecar = value;

  void doWheelie([double duration = 2.0]) {
    print('Doing wheelie for $duration seconds on $model');
  }
}

class Truck extends Vehicle with Acceleratable, Repairable, Stoppable, Movable {
  double _cargoCapacity;

  Truck(String model, int year, double speed, this._cargoCapacity)
      : super(model, year, speed);

  // Именованный конструктор
  Truck.basic() : this('Basic Truck', 2018, 0, 10.0);

  double get cargoCapacity => _cargoCapacity;
  set cargoCapacity(double value) => _cargoCapacity = value;

  void loadCargo(double weight, {String type = "general"}) {
    print('Loading $weight kg of $type cargo on $model');
  }
}