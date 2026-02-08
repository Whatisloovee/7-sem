import 'package:flutter/material.dart';

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
      home: const DiscoverScreen(),
    );
  }
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

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
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
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
                      width: 120, // Увеличил ширину для размещения трех цветков с наложением
                      height: 80,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Positioned(
                            right: 35,
                            bottom: 20,// Смещение для наложения
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/flow2.png'), // Замените на ваш URL
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Задний цветок 1 (смещен влево)
                          Positioned(
                            right: 50,
                            top: 15,// Смещение для наложения
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/flow.png'), // Замените на ваш URL
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Задний цветок 2 (смещен чуть меньше)

                          // Передний цветок (без смещения)
                          Positioned(
                            right: -5,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/flow3.png'), // Замените на ваш URL
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
                  children: [
                    _ProductCard(
                      name: 'Aloe Vera',
                      price: 60,
                      image: 'https://www.cmp24.ru/images/prodacts/sourse/105628/105628848_aloe-vera-d12-h35-lerua-merlen.jpg', // Replace with actual image URL or asset
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProductDetailScreen()),
                        );
                      },
                    ),
                    _ProductCard(
                      name: 'Bonsai',
                      price: 60,
                      image: 'https://avatars.mds.yandex.net/i?id=367d93fe8bce347503f548aba6cd32b5e40f91e7-12635770-images-thumbs&n=13', // Replace with actual image URL or asset
                    ),
                    _ProductCard(
                      name: 'Bonsai',
                      price: 60,
                      image: 'https://avatars.mds.yandex.net/i?id=367d93fe8bce347503f548aba6cd32b5e40f91e7-12635770-images-thumbs&n=13', // Replace with actual image URL or asset
                    ),
                    _ProductCard(
                      name: 'Bonsai',
                      price: 60,
                      image: 'https://avatars.mds.yandex.net/i?id=367d93fe8bce347503f548aba6cd32b5e40f91e7-12635770-images-thumbs&n=13', // Replace with actual image URL or asset
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Отступы от низа и боков
        padding: const EdgeInsets.symmetric(vertical: 20), // Добавлен вертикальный отступ для высоты
        decoration: BoxDecoration(
          color: const Color(0xFF94a561), // Зеленоватый фон, как на картинке
          borderRadius: BorderRadius.circular(60), // Овальная форма
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Равномерное распределение иконок
          children: [
            Icon(Icons.home_outlined, color: Colors.white, size: 24),
            Icon(Icons.favorite_border, color: Colors.white, size: 24),
            Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
            Icon(Icons.more_horiz, color: Colors.white, size: 24),
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
  final String name;
  final double price;
  final String image;
  final VoidCallback? onTap;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.image,
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
                    image: NetworkImage(widget.image),
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
                      widget.name,
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
                      '\$${widget.price}',
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
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF94a561),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and icons
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

            // Product Image
            Expanded(
              flex: 2,
              child: Container(
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
                    'https://www.cmp24.ru/images/prodacts/sourse/105628/105628848_aloe-vera-d12-h35-lerua-merlen.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            // Product Details Card
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
                      children: const [
                        Text(
                          'Aloe Vera',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Lidah Buaya',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Fertilize sparingly (no more than once a month), and only in the spring and summer with a balanced houseplant formula mixed at ½ strength.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Care Icons Slider
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

                    // Bottom Row with Quantity and Checkout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Minus button
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero, // Убираем все отступы
                                iconSize: 18, // Уменьшаем размер иконки
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
                            // Plus button
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero, // Убираем все отступы
                                iconSize: 18, // Уменьшаем размер иконки
                                icon: const Icon(Icons.add),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),

                        // Checkout Button
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF41612c),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Checkout \$60',
                            style: TextStyle(
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