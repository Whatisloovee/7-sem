// screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/product_provider.dart';
import '../providers/favorite_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final productProvider = context.watch<ProductProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();

    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Пользователь не выбран')),
      );
    }

    final favorites = favoriteProvider.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final favorite = favorites[index];
          final product = productProvider.getProductById(favorite.productId);
          if (product == null) return const SizedBox.shrink();
          return ListTile(
            leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(product.name),
            subtitle: Text('\$${product.price}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                favoriteProvider.deleteFavorite(favorite.id, currentUser.id);
              },
            ),
          );
        },
      ),
    );
  }
}