import 'package:flutter/material.dart';
import 'vehicle.dart';
import 'database_helper.dart';
import 'file_operations.dart';

class VehicleEditScreen extends StatefulWidget {
  final Vehicle? vehicle;

  VehicleEditScreen({this.vehicle});

  @override
  _VehicleEditScreenState createState() => _VehicleEditScreenState();
}

class _VehicleEditScreenState extends State<VehicleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Car';
  String _model = '';
  int _year = 2020;
  double _speed = 0.0;
  int _doors = 4;
  bool _hasSidecar = false;
  double _cargoCapacity = 10.0;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _type = widget.vehicle!.type; // Используем геттер type вместо _type
      _model = widget.vehicle!.model;
      _year = widget.vehicle!.year;
      _speed = widget.vehicle!.speed;
      if (widget.vehicle is Car) {
        _doors = (widget.vehicle as Car).doors;
      } else if (widget.vehicle is Motorcycle) {
        _hasSidecar = (widget.vehicle as Motorcycle).hasSidecar;
      } else if (widget.vehicle is Truck) {
        _cargoCapacity = (widget.vehicle as Truck).cargoCapacity;
      }
    }
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Vehicle vehicle;
      if (_type == 'Car') {
        vehicle = Car(null, _model, _year, _speed, _doors);
      } else if (_type == 'Motorcycle') {
        vehicle = Motorcycle(null, _model, _year, _speed, _hasSidecar);
      } else {
        vehicle = Truck(null, _model, _year, _speed, _cargoCapacity);
      }
      if (widget.vehicle == null) {
        await _dbHelper.insertVehicle(vehicle);
      } else {
        vehicle.id = widget.vehicle!.id;
        await _dbHelper.updateVehicle(vehicle);
      }
      await FileOperations.saveVehicleToFiles(vehicle);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Car', 'Motorcycle', 'Truck']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
                decoration: InputDecoration(labelText: 'Vehicle Type'),
              ),
              TextFormField(
                initialValue: _model,
                decoration: InputDecoration(labelText: 'Model'),
                validator: (value) => value!.isEmpty ? 'Enter a model' : null,
                onSaved: (value) => _model = value!,
              ),
              TextFormField(
                initialValue: _year.toString(),
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) => int.tryParse(value!) == null ? 'Enter a valid year' : null,
                onSaved: (value) => _year = int.parse(value!),
              ),
              TextFormField(
                initialValue: _speed.toString(),
                decoration: InputDecoration(labelText: 'Speed (km/h)'),
                keyboardType: TextInputType.number,
                validator: (value) => double.tryParse(value!) == null ? 'Enter a valid speed' : null,
                onSaved: (value) => _speed = double.parse(value!),
              ),
              if (_type == 'Car')
                TextFormField(
                  initialValue: _doors.toString(),
                  decoration: InputDecoration(labelText: 'Doors'),
                  keyboardType: TextInputType.number,
                  validator: (value) => int.tryParse(value!) == null ? 'Enter a valid number' : null,
                  onSaved: (value) => _doors = int.parse(value!),
                ),
              if (_type == 'Motorcycle')
                CheckboxListTile(
                  title: Text('Has Sidecar'),
                  value: _hasSidecar,
                  onChanged: (value) => setState(() => _hasSidecar = value!),
                ),
              if (_type == 'Truck')
                TextFormField(
                  initialValue: _cargoCapacity.toString(),
                  decoration: InputDecoration(labelText: 'Cargo Capacity (tons)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => double.tryParse(value!) == null ? 'Enter a valid number' : null,
                  onSaved: (value) => _cargoCapacity = double.parse(value!),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVehicle,
                child: Text(widget.vehicle == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}