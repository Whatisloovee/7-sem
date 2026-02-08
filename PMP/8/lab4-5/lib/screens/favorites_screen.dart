import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/favorite.dart';
import '../services/hive_service.dart';

class FavoritesScreen extends StatelessWidget {
  final User currentUser;

  const FavoritesScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: ValueListenableBuilder<Box<Favorite>>(
        valueListenable: HiveService.favoriteBox.listenable(),
        builder: (context, box, _) {
          final favorites = HiveService.getFavorites(currentUser.id);
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              final product = HiveService.productBox.get(favorite.productId);
              if (product == null) return const SizedBox.shrink();
              return ListTile(
                leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(product.name),
                subtitle: Text('\$${product.price}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    HiveService.deleteFavorite(favorite.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}