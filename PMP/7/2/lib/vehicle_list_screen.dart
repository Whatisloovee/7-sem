import 'package:flutter/material.dart';
import 'vehicle.dart';
import 'vehicle_edit_screen.dart';
import 'database_helper.dart';
import 'file_operations.dart';
import 'file_contents_screen.dart';

class VehicleListScreen extends StatefulWidget {
  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  List<Vehicle> vehicles = [];
  List<Vehicle> filteredVehicles = [];
  final TextEditingController _searchController = TextEditingController();
  String sortBy = 'model';
  bool ascending = true;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> savedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _searchController.addListener(_filterVehicles);
    _loadSavedFiles();
  }

  Future<void> _loadVehicles() async {
    final loadedVehicles = await _dbHelper.getVehicles();
    setState(() {
      vehicles = loadedVehicles;
      _filterVehicles();
    });
  }

  void _filterVehicles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredVehicles = vehicles.where((vehicle) {
        return vehicle.model.toLowerCase().contains(query) ||
            vehicle.getInfo().toLowerCase().contains(query);
      }).toList();
      _sortVehicles();
    });
  }

  void _sortVehicles() {
    filteredVehicles.sort((a, b) {
      int compare;
      switch (sortBy) {
        case 'model':
          compare = a.model.compareTo(b.model);
          break;
        case 'year':
          compare = a.year.compareTo(b.year);
          break;
        case 'speed':
          compare = a.speed.compareTo(b.speed);
          break;
        default:
          compare = a.model.compareTo(b.model);
      }
      return ascending ? compare : -compare;
    });
  }

  Future<void> _deleteVehicle(int id) async {
    await _dbHelper.deleteVehicle(id);
    _loadVehicles();
  }

  Future<void> _loadSavedFiles() async {
    final files = await FileOperations.listSavedFiles();
    setState(() {
      savedFiles = files;
    });
  }


  Future<void> _showFileContents() async {
    final contents = await FileOperations.readSavedFilesContent();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileContentsScreen(contents: contents),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle List'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_open),
            onPressed: _showFileContents,
            tooltip: 'View File Contents',
          ),
          IconButton(
            icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                ascending = !ascending;
                _sortVehicles();
              });
            },
            tooltip: 'Toggle Sort Order',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortBy = value;
                _sortVehicles();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'model', child: Text('Sort by Model')),
              PopupMenuItem(value: 'year', child: Text('Sort by Year')),
              PopupMenuItem(value: 'speed', child: Text('Sort by Speed')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemExtent: 80.0, // Fixed item height
              itemCount: filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = filteredVehicles[index];
                return ListTile(
                  title: Text(vehicle.model),
                  subtitle: Text(vehicle.getInfo()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VehicleEditScreen(vehicle: vehicle),
                      ),
                    ).then((_) => _loadVehicles());
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteVehicle(vehicle.id!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saved Files:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...savedFiles.map((file) => Text(file)).toList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleEditScreen(),
            ),
          ).then((_) => _loadVehicles());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}