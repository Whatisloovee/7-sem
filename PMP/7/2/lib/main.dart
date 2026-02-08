import 'package:flutter/material.dart';
import 'vehicle_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Manager',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: VehicleListScreen(),
    );
  }
}