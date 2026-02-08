import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/favorite.dart';
import 'product_detail_screen.dart';
import 'admin_screen.dart';
import 'favorites_screen.dart';
import 'user_selection_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        if (userState is! UserLoaded || userState.currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Пользователь не выбран')),
          );
        }

        final currentUser = userState.currentUser!;
        // Загружаем избранное один раз
        context.read<FavoriteBloc>().add(LoadFavorites(currentUser.id));

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
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    );
                  },
                ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  context.read<UserBloc>().add(LogoutUser());
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const UserSelectionScreen()),
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
                    children: const [
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
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, productState) {
                        if (productState is! ProductLoaded) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                          children: productState.products.map((product) {
                            return _ProductCard(
                              product: product,
                              currentUser: currentUser,
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
                const Icon(Icons.home_outlined, color: Colors.white, size: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                    );
                  },
                  child: const Icon(Icons.favorite_border, color: Colors.white, size: 24),
                ),
                const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                const Icon(Icons.more_horiz, color: Colors.white, size: 24),
              ],
            ),
          ),
        );
      },
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
        onTap: () => setState(() => isSelected = !isSelected),
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 1)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.green, size: 30),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
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

class _ProductCard extends StatelessWidget {
  final Product product;
  final User currentUser;

  const _ProductCard({required this.product, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        final isFavorite = favoriteState is FavoriteLoaded &&
            context.read<FavoriteBloc>().isProductFavorite(product.id, currentUser.id, favoriteState.favorites);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: DecorationImage(image: NetworkImage(product.image), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            final bloc = context.read<FavoriteBloc>();
                            final id = bloc.getFavoriteId(product.id, currentUser.id);
                            if (isFavorite) {
                              bloc.add(DeleteFavorite(id, currentUser.id));
                            } else {
                              bloc.add(AddFavorite(Favorite(id: id, userId: currentUser.id, productId: product.id)));
                            }
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
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text('\$${product.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}