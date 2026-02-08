// Интерфейс
abstract interface class Transportable {
  void move();
  void stop();
  String getInfo();
}

// Абстрактный класс
abstract class Vehicle implements Transportable {
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

  @override
  void move();

  @override
  void stop();

  // Статический метод
  static String getTotalVehiclesString() {
    return 'Total vehicles created: $totalVehicles';
  }

  // Метод с параметром по умолчанию
  void accelerate([double amount = 10.0]) {
    _speed += amount;
  }

  // Метод с именованным параметром
  void repair({bool urgent = false, double cost = 100.0}) {}

  // Метод с параметром типа функция
  void performMaintenance(void Function(String) callback) {
    callback('Maintenance performed on $_model');
  }

  @override
  String getInfo() {
    return 'Model: $_model, Year: $_year, Speed: $_speed km/h';
  }
}

// Конкретные классы
class Car extends Vehicle {
  int _doors;

  Car(String model, int year, double speed, this._doors) : super(model, year, speed);

  // Именованный конструктор
  Car.basic() : this('Toyota Basic', 2020, 0, 2);

  int get doors => _doors;
  set doors(int value) => _doors = value;

  @override
  void move() {}

  @override
  void stop() {
    _speed = 0;
  }

  void openDoors([int doorNumber = 1]) {}
}

class Motorcycle extends Vehicle {
  bool _hasSidecar;

  Motorcycle(String model, int year, double speed, this._hasSidecar)
      : super(model, year, speed);

  // Именованный конструктор
  Motorcycle.basic() : this('Basic Motorcycle', 2019, 0, false);

  bool get hasSidecar => _hasSidecar;
  set hasSidecar(bool value) => _hasSidecar = value;

  @override
  void move() {}

  @override
  void stop() {
    _speed = 0;
  }

  void doWheelie([double duration = 2.0]) {}
}

class Truck extends Vehicle {
  double _cargoCapacity;

  Truck(String model, int year, double speed, this._cargoCapacity)
      : super(model, year, speed);

  // Именованный конструктор
  Truck.basic() : this('Basic Truck', 2018, 0, 10.0);

  double get cargoCapacity => _cargoCapacity;
  set cargoCapacity(double value) => _cargoCapacity = value;

  @override
  void move() {}

  @override
  void stop() {
    _speed = 0;
  }

  void loadCargo(double weight, {String type = "general"}) {}
}