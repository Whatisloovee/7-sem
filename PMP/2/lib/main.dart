import 'package:flutter/material.dart';
import 'transport.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Lab 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: TransportDemoScreen(),
    );
  }
}

class TransportDemoScreen extends StatefulWidget {
  @override
  _TransportDemoScreenState createState() => _TransportDemoScreenState();
}

class _TransportDemoScreenState extends State<TransportDemoScreen> {
  List<String> outputLines = [];
  final ScrollController _scrollController = ScrollController();

  void _addOutput(String text) {
    setState(() {
      outputLines.add(text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearOutput() {
    setState(() {
      outputLines.clear();
    });
  }

  void _demonstrateTransport() {
    _clearOutput();
    _addOutput('Starting Transport Demonstration...\n');

    // Создание объектов с использованием обычных и именованных конструкторов
    _addOutput('=====Creating Objects=====');
    var car = Car('Toyota Camry', 2022, 0, 4);
    _addOutput('Created Car: ${car.getInfo()}');
    var basicCar = Car.basic();
    _addOutput('Created Basic Car (named constructor): ${basicCar.getInfo()}');
    var motorcycle = Motorcycle('Harley Davidson', 2021, 0, false);
    _addOutput('Created Motorcycle: ${motorcycle.getInfo()}');
    var truck = Truck('Volvo FH16', 2020, 0, 20.0);
    _addOutput('Created Truck: ${truck.getInfo()}');

    // Демонстрация работы с массивом (List как массив)
    _addOutput('\n=====Array Demonstration=====');
    List<Vehicle> vehicles = [car, basicCar, motorcycle, truck];

    for (var vehicle in vehicles) {
      _addOutput('Calling move on ${vehicle.model}');
      vehicle.move();
      _addOutput('Calling accelerate(30.0) on ${vehicle.model}');
      vehicle.accelerate(30.0);
      _addOutput(vehicle.getInfo());
    }

    // Демонстрация работы с коллекцией (использование map и toList)
    _addOutput('\n=====Collection Demonstration=====');
    List<String> vehicleModels = vehicles.map((v) => v.model).toList();
    vehicleModels.forEach((model) => _addOutput('Model: $model'));

    // Демонстрация работы с множеством (Set)
    _addOutput('\n=====Set Demonstration=====');
    Set<int> years = {2020, 2021, 2022, 2022, 2021};
    years.forEach((year) => _addOutput('Year: $year'));

    // Демонстрация continue и break
    _addOutput('\n=====Continue/Break Demonstration=====');
    for (int i = 0; i < 10; i++) {
      if (i == 2) continue;
      if (i == 7) break;
      _addOutput('Index: $i');
    }

    // Демонстрация обработки исключений
    _addOutput('\n=====Exception Handling=====');
    try {
      Car testCar = Car('Test Car', 2023, 0, 4);
      testCar.speed = -50;
      if (testCar.speed < 0) {
        throw Exception('Speed cannot be negative');
      }
    } catch (e) {
      _addOutput('Error: $e');
    } finally {
      _addOutput('Exception handling completed');
    }

    // Демонстрация методов
    _addOutput('\n=====Method Demonstration=====');
    _addOutput('Calling openDoors(2) on car (optional parameter)');
    car.openDoors(2);
    _addOutput('Calling repair(urgent: true, cost: 250.0) on car (named parameters)');
    car.repair(urgent: true, cost: 250.0);

    _addOutput('Calling performMaintenance on truck (function parameter)');
    truck.performMaintenance((message) {
      _addOutput('Callback: $message');
    });

    _addOutput('Calling doWheelie(3.0) on motorcycle');
    motorcycle.doWheelie(3.0);
    _addOutput('Calling loadCargo(15.0, type: "construction") on truck (named parameter)');
    truck.loadCargo(15.0, type: "construction");

    // Статические поля и методы
    _addOutput('\n=====Static Demonstration=====');
    _addOutput(Vehicle.getTotalVehiclesString());

    // Getter/Setter
    _addOutput('\n=====Getter/Setter Demonstration=====');
    _addOutput('Original car doors: ${car.doors}');
    car.doors = 5;
    _addOutput('Modified car doors: ${car.doors}');

    // Параметры по умолчанию
    _addOutput('\n=====Default Parameter Demonstration=====');
    _addOutput('Calling accelerate() without parameter on car:');
    car.accelerate(); // Использует значение по умолчанию (10.0)
    _addOutput('Current speed: ${car.speed} km/h');

    _addOutput('\nCalling accelerate(25.0) with parameter on car:');
    car.accelerate(25.0); // Использует переданное значение
    _addOutput('Current speed: ${car.speed} km/h');

    _addOutput('\nCalling openDoors() without parameter on car:');
    car.openDoors(); // Использует значение по умолчанию (1)
    _addOutput('\nCalling openDoors(3) with parameter on car:');
    car.openDoors(3); // Использует переданное значение

    _addOutput('\nCalling doWheelie() without parameter on motorcycle:');
    motorcycle.doWheelie(); // Использует значение по умолчанию (2.0)
    _addOutput('\nCalling doWheelie(5.0) with parameter on motorcycle:');
    motorcycle.doWheelie(5.0); // Использует переданное значение

    _addOutput('\n=====Demonstration completed=====');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transport Laboratory Work'),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearOutput,
            tooltip: 'Clear output',
          ),
        ],
      ),
      body: Column(
        children: [
          // Кнопки управления
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _demonstrateTransport,
                  icon: Icon(Icons.play_arrow),
                  label: Text('Run Demo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearOutput,
                  icon: Icon(Icons.clear),
                  label: Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Область вывода
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
              child: outputLines.isEmpty
                  ? Center(
                child: Text(
                  'Press "Run Demo" to start...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                itemCount: outputLines.length,
                itemBuilder: (context, index) {
                  return Text(
                    outputLines[index],
                    style: TextStyle(
                      color: Colors.lightGreen,
                      fontSize: 14,
                      fontFamily: 'Monospace',
                    ),
                  );
                },
              ),
            ),
          ),

          // Статус бар
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.blueGrey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total vehicles: ${Vehicle.totalVehicles}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Lines: ${outputLines.length}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _demonstrateTransport,
        child: Icon(Icons.play_arrow),
        backgroundColor: Colors.green,
      ),
    );
  }
}