import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'transport.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Lab 3',
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

  Future<void> _demonstrateTransport() async {
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

    // Демонстрация mixins (accelerate, repair, move, stop)
    _addOutput('\n=====Mixins Demonstration=====');
    car.accelerate(20.0);
    _addOutput('Accelerated car: ${car.getInfo()}');
    car.repair(urgent: true, cost: 300.0);
    car.move();
    car.stop();
    _addOutput('Stopped car: ${car.getInfo()}');
    motorcycle.accelerate();
    _addOutput('Accelerated motorcycle: ${motorcycle.getInfo()}');
    truck.move();

    // Демонстрация Comparable
    _addOutput('\n=====Comparable Demonstration=====');
    _addOutput('Comparing car (2022) and motorcycle (2021): ${car.compareTo(motorcycle)} (should be >0)');
    _addOutput('Comparing truck (2020) and basicCar (2020): ${truck.compareTo(basicCar)} (should be 0)');

    // Демонстрация Iterator и Iterable
    _addOutput('\n=====Iterable/Iterator Demonstration=====');
    var fleet = VehicleFleet();
    fleet.add(car);
    fleet.add(motorcycle);
    fleet.add(truck);
    for (var vehicle in fleet) {
      _addOutput('Fleet vehicle: ${vehicle.getInfo()}');
    }

    // Демонстрация сериализации в JSON
    _addOutput('\n=====JSON Serialization Demonstration=====');
    String carJson = jsonEncode(car.toJson());
    _addOutput('Car JSON: $carJson');

    // Демонстрация асинхронного метода и Future
    _addOutput('\n=====Async Method and Future Demonstration=====');
    _addOutput('Starting engine async...');
    Future<void> engineFuture = car.startEngine();
    await engineFuture;
    _addOutput('Engine started (awaited Future)');

    // Демонстрация Stream (Single subscription и Broadcast)
    _addOutput('\n=====Stream Demonstration=====');
    _addOutput('Single subscription stream:');
    var singleStream = car.speedStream();
    singleStream.listen(
          (speed) => _addOutput('Single stream speed: $speed'),
      onDone: () => _addOutput('Single stream done'),
    );
    // Ждем завершения стрима (5 секунд)
    await Future.delayed(Duration(seconds: 6));

    _addOutput('\nBroadcast stream:');
    var broadcastController = StreamController<double>.broadcast();
    broadcastController.stream.listen((speed) => _addOutput('Listener 1: $speed'));
    broadcastController.stream.listen((speed) => _addOutput('Listener 2: $speed'));
    broadcastController.sink.add(10.0);
    broadcastController.sink.add(20.0);
    broadcastController.sink.add(30.0);
    await broadcastController.close();
    _addOutput('Broadcast stream closed');

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