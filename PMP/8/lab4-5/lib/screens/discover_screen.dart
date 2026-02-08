import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/favorite.dart';
import '../services/hive_service.dart';
import 'product_detail_screen.dart';
import 'admin_screen.dart';
import 'favorites_screen.dart';
import 'user_selection_screen.dart';

class DiscoverScreen extends StatelessWidget {
  final User currentUser;

  const DiscoverScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          if (currentUser.role == 'admin' || currentUser.role == 'manager')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminScreen(currentUser: currentUser)),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  color: const Color(0xFFdcde9f),
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
                child: ValueListenableBuilder<Box<Product>>(
                  valueListenable: HiveService.productBox.listenable(),
                  builder: (context, box, _) {
                    final products = box.values.toList();
                    if (products.isEmpty) {
                      HiveService.addProduct(Product(
                        id: '1',
                        name: 'Aloe Vera',
                        price: 60,
                        image: 'https://www.cmp24.ru/images/prodacts/sourse/105628/105628848_aloe-vera-d12-h35-lerua-merlen.jpg',
                      ));
                      HiveService.addProduct(Product(
                        id: '2',
                        name: 'Bonsai',
                        price: 60,
                        image: 'https://avatars.mds.yandex.net/i?id=367d93fe8bce347503f548aba6cd32b5e40f91e7-12635770-images-thumbs&n=13',
                      ));
                    }
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                      children: products.map((product) {
                        return _ProductCard(
                          id: product.id,
                          name: product.name,
                          price: product.price,
                          image: product.image,
                          currentUser: currentUser,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  product: product,
                                  currentUser: currentUser,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(currentUser: currentUser),
                  ),
                );
              },
              child: Icon(Icons.favorite_border, color: Colors.white, size: 24),
            ),
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
  final String id;
  final String name;
  final double price;
  final String image;
  final User currentUser;
  final VoidCallback? onTap;

  const _ProductCard({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.currentUser,
    this.onTap,
  });

  @override
  State<_ProductCard> createState() => __ProductCardState();
}

class __ProductCardState extends State<_ProductCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    final favorites = HiveService.getFavorites(widget.currentUser.id);
    isFavorite = favorites.any((f) => f.productId == widget.id);
  }

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
                            if (isFavorite) {
                              HiveService.addFavorite(Favorite(
                                id: '${widget.currentUser.id}_${widget.id}',
                                userId: widget.currentUser.id,
                                productId: widget.id,
                              ));
                            } else {
                              HiveService.deleteFavorite('${widget.currentUser.id}_${widget.id}');
                            }
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