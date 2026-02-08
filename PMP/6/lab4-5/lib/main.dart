import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Shop',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green[50],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DiscoverScreen(),
        '/details': (context) => const ProductDetailScreen(),
        '/cart': (context) => const CartScreen(),
        '/device_info': (context) => const DeviceInfoScreen(),
      },
    );
  }
}

class Product {
  final String name;
  final double price;
  final String image;
  final String description;

  const Product({
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  final List<Product> products = const [
    Product(
      name: 'Aloe Vera',
      price: 60,
      image: 'https://www.cmp24.ru/images/prodacts/sourse/105628/105628848_aloe-vera-d12-h35-lerua-merlen.jpg',
      description: 'Fertilize sparingly (no more than once a month), and only in the spring and summer with a balanced houseplant formula mixed at ½ strength.',
    ),
    Product(
      name: 'Bonsai',
      price: 60,
      image: 'https://avatars.mds.yandex.net/i?id=367d93fe8bce347503f548aba6cd32b5e40f91e7-12635770-images-thumbs&n=13',
      description: 'Requires careful pruning and shaping with indirect sunlight and consistent moisture.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Discover',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/cart');
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _CategoryButton(icon: Icons.park_outlined, label: 'Green Plants'),
                  _CategoryButton(icon: Icons.local_florist_outlined, label: 'Flowers'),
                  _CategoryButton(icon: Icons.eco_outlined, label: 'Indoor Plant'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFdcde9f),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Get', style: TextStyle(fontSize: 14)),
                          Text('20% off', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                          Text('For Today', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Positioned(
                            right: 35,
                            bottom: 20,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/flow2.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 50,
                            top: 15,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/flow.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -5,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/flow3.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                  children: products
                      .asMap()
                      .entries
                      .map((entry) => _ProductCard(
                    product: entry.value,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: entry.value),
                        ),
                      );
                    },
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF94a561),
          borderRadius: BorderRadius.circular(60),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.home_outlined, color: Colors.white, size: 24),
            Icon(Icons.favorite_border, color: Colors.white, size: 24),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
              child: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/device_info');
              },
              child: Icon(Icons.info_outline, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryButton extends StatefulWidget {
  final IconData icon;
  final String label;

  const _CategoryButton({required this.icon, required this.label});

  @override
  State<_CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<_CategoryButton> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isSelected = !isSelected;
          });
        },
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: Colors.green,
                size: 30,
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const _ProductCard({
    required this.product,
    this.onTap,
  });

  @override
  State<_ProductCard> createState() => __ProductCardState();
}

class __ProductCardState extends State<_ProductCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(widget.product.image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${widget.product.price}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Product? product;

  const ProductDetailScreen({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF94a561),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.share, color: Colors.white, size: 24),
                      SizedBox(width: 16),
                      Icon(Icons.favorite_border, color: Colors.white, size: 24),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: PageView(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        product?.image ?? 'https://www.cmp24.ru/images/prodacts/sourse/105628/105628848_aloe-vera-d12-h35-lerua-merlen.jpg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        product?.image ?? 'https://avatars.mds.yandex.net/i?id=367d93fe8bce347503f548aba6cd32b5e40f91e7-12635770-images-thumbs&n=13',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product?.name ?? 'Aloe Vera',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          product?.name == 'Aloe Vera' ? 'Lidah Buaya' : 'Bonsai Tree',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product?.description ?? 'Fertilize sparingly (no more than once a month), and only in the spring and summer with a balanced houseplant formula mixed at ½ strength.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          SizedBox(width: 8),
                          _CareCard(
                            icon: Icons.water_drop,
                            label: 'Drained',
                            subtitle: 'Watering',
                          ),
                          _CareCard(
                            icon: Icons.wb_sunny,
                            label: 'Full Sun',
                            subtitle: 'Sunlight',
                          ),
                          _CareCard(
                            icon: Icons.straighten,
                            label: '30 x 50 cm',
                            subtitle: 'Size',
                          ),
                          _CareCard(
                            icon: Icons.thermostat,
                            label: '13-27°C',
                            subtitle: 'Temperature',
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                                icon: const Icon(Icons.remove),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '1',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                                icon: const Icon(Icons.add),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/cart');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF41612c),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Checkout \$${product?.price ?? 60}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _CareCard({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.green[600],
            size: 28,
          ),
          const SizedBox(height: 15),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text(
          'Shopping Cart',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  static const gpsChannel = MethodChannel('com.example.lab4_5/gps');
  static const batteryChannel = MethodChannel('com.example.lab4_5/battery');
  static const alarmChannel = MethodChannel('com.example.lab4_5/alarm');
  String _gpsStatus = 'Unknown';
  String _batteryLevel = 'Unknown';
  bool _isLoadingGps = false;
  bool _isLoadingBattery = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _hourController = TextEditingController(text: '12');
  final TextEditingController _minuteController = TextEditingController(text: '00');
  String _alarmStatus = '';

  @override
  void initState() {
    super.initState();
    _checkGpsStatus();
    _getBatteryLevel();
  }

  Future<void> _checkGpsStatus() async {
    setState(() {
      _isLoadingGps = true;
    });
    try {
      if (await Permission.location.request().isGranted) {
        final bool isGpsEnabled = await gpsChannel.invokeMethod('isGpsEnabled');
        setState(() {
          _gpsStatus = isGpsEnabled ? 'GPS is Enabled' : 'GPS is Disabled';
          _isLoadingGps = false;
        });
      } else {
        setState(() {
          _gpsStatus = 'Location permission denied';
          _isLoadingGps = false;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _gpsStatus = 'Error: ${e.message}';
        _isLoadingGps = false;
      });
    }
  }

  Future<void> _getBatteryLevel() async {
    setState(() {
      _isLoadingBattery = true;
    });
    try {
      final int batteryLevel = await batteryChannel.invokeMethod('getBatteryLevel');
      setState(() {
        _batteryLevel = '$batteryLevel%';
        _isLoadingBattery = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _batteryLevel = 'Error: ${e.message}';
        _isLoadingBattery = false;
      });
    }
  }



  Future<void> _setAlarm() async {
    setState(() {
      _alarmStatus = 'Открываем приложение Часы...';
    });
    try {
      final int? hour = int.tryParse(_hourController.text);
      final int? minute = int.tryParse(_minuteController.text);
      if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        setState(() {
          _alarmStatus = 'Неверный формат времени (часы: 0-23, минуты: 0-59)';
        });
        return;
      }
      await alarmChannel.invokeMethod('setAlarm', {
        'hour': hour,
        'minute': minute,
      });
      setState(() {
        _alarmStatus = 'Будильник на $hour:${minute.toString().padLeft(2, '0')} передан в приложение Часы. Подтвердите или добавьте вручную.';
      });
    } on PlatformException catch (e) {
      setState(() {
        _alarmStatus = 'Ошибка: ${e.message}. Добавьте будильник вручную.';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      if (await Permission.camera.request().isGranted) {
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
          });
        }
      } else {
        setState(() {
          _image = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // GPS Status
            _isLoadingGps
                ? const CircularProgressIndicator()
                : Text(
              _gpsStatus,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkGpsStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF41612c),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Refresh GPS Status'),
            ),
            const SizedBox(height: 20),
            // Battery Level
            _isLoadingBattery
                ? const CircularProgressIndicator()
                : Text(
              'Battery Level: $_batteryLevel',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getBatteryLevel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF41612c),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Refresh Battery Level'),
            ),
            const SizedBox(height: 20),
            // Alarm Setting
            const Text(
              'Set Alarm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _hourController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hour',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _minuteController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minute',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _setAlarm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF41612c),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Set Alarm'),
            ),
            const SizedBox(height: 10),
            Text(
              _alarmStatus,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Camera
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF41612c),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Take Photo'),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              const Text(
                'No photo taken',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }
}