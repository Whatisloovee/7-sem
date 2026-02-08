abstract interface class Transportable {
  void move();
  void stop();
  String getInfo();
}

abstract class Vehicle implements Transportable {
  static int totalVehicles = 0;

  int? id;
  String _model;
  int _year;
  double _speed;
  String _type;

  Vehicle(this.id, this._model, this._year, this._speed, this._type) {
    totalVehicles++;
  }

  String get model => _model;
  set model(String value) => _model = value;

  int get year => _year;
  set year(int value) => _year = value;

  double get speed => _speed;
  set speed(double value) => _speed = value;

  String get type => _type; // Добавляем геттер для _type

  @override
  void move() {}

  @override
  void stop() {
    _speed = 0;
  }

  static String getTotalVehiclesString() {
    return 'Total vehicles created: $totalVehicles';
  }

  void accelerate([double amount = 10.0]) {
    _speed += amount;
  }

  void repair({bool urgent = false, double cost = 100.0}) {}

  void performMaintenance(void Function(String) callback) {
    callback('Maintenance performed on $_model');
  }

  @override
  String getInfo() {
    return 'Model: $_model, Year: $_year, Speed: $_speed km/h';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model': _model,
      'year': _year,
      'speed': _speed,
      'type': _type,
    };
  }

  static Vehicle fromMap(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'Car':
        return Car.fromMap(map);
      case 'Motorcycle':
        return Motorcycle.fromMap(map);
      case 'Truck':
        return Truck.fromMap(map);
      default:
        throw Exception('Unknown vehicle type');
    }
  }
}

class Car extends Vehicle {
  int _doors;

  Car(int? id, String model, int year, double speed, this._doors)
      : super(id, model, year, speed, 'Car');

  Car.basic() : this(null, 'Toyota Basic', 2020, 0, 2);

  Car.fromMap(Map<String, dynamic> map)
      : _doors = map['doors'],
        super(map['id'], map['model'], map['year'], map['speed'], 'Car');

  int get doors => _doors;
  set doors(int value) => _doors = value;

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['doors'] = _doors;
    return map;
  }

  @override
  void move() {}

  @override
  void stop() {
    _speed = 0;
  }

  void openDoors([int doorNumber = 1]) {}

  @override
  String getInfo() {
    return '${super.getInfo()}, Doors: $_doors';
  }
}

class Motorcycle extends Vehicle {
  bool _hasSidecar;

  Motorcycle(int? id, String model, int year, double speed, this._hasSidecar)
      : super(id, model, year, speed, 'Motorcycle');

  Motorcycle.basic() : this(null, 'Basic Motorcycle', 2019, 0, false);

  Motorcycle.fromMap(Map<String, dynamic> map)
      : _hasSidecar = map['hasSidecar'] == 1,
        super(map['id'], map['model'], map['year'], map['speed'], 'Motorcycle');

  bool get hasSidecar => _hasSidecar;
  set hasSidecar(bool value) => _hasSidecar = value;

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['hasSidecar'] = _hasSidecar ? 1 : 0;
    return map;
  }

  @override
  void move() {}

  @override
  void stop() {
    _speed = 0;
  }

  void doWheelie([double duration = 2.0]) {}

  @override
  String getInfo() {
    return '${super.getInfo()}, Has Sidecar: $_hasSidecar';
  }
}

class Truck extends Vehicle {
  double _cargoCapacity;

  Truck(int? id, String model, int year, double speed, this._cargoCapacity)
      : super(id, model, year, speed, 'Truck');

  Truck.basic() : this(null, 'Basic Truck', 2018, 0, 10.0);

  Truck.fromMap(Map<String, dynamic> map)
      : _cargoCapacity = map['cargoCapacity'],
        super(map['id'], map['model'], map['year'], map['speed'], 'Truck');

  double get cargoCapacity => _cargoCapacity;
  set cargoCapacity(double value) => _cargoCapacity = value;

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['cargoCapacity'] = _cargoCapacity;
    return map;
  }

  @override
  void move() {}

  @override
  void stop() {
    _speed = 0;
  }

  void loadCargo(double weight, {String type = "general"}) {}

  @override
  String getInfo() {
    return '${super.getInfo()}, Cargo Capacity: $_cargoCapacity';
  }
}