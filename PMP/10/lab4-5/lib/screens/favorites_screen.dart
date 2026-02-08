import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../models/product.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        if (userState is! UserLoaded || userState.currentUser == null) {
          return const Scaffold(body: Center(child: Text('Пользователь не выбран')));
        }

        final userId = userState.currentUser!.id;
        context.read<FavoriteBloc>().add(LoadFavorites(userId));

        return Scaffold(
          appBar: AppBar(title: const Text('Избранное')),
          body: BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, favoriteState) {
              if (favoriteState is FavoriteLoaded) {
                return ListView.builder(
                  itemCount: favoriteState.favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = favoriteState.favorites[index];
                    final product = context.read<ProductBloc>().state is ProductLoaded
                        ? (context.read<ProductBloc>().state as ProductLoaded).products.firstWhere((p) => p.id == favorite.productId, orElse: () => Product(id: '', name: 'Удалено', price: 0, image: ''))
                        : null;
                    if (product == null || product.id.isEmpty) return const SizedBox.shrink();
                    return ListTile(
                      leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(product.name),
                      subtitle: Text('\$${product.price}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => context.read<FavoriteBloc>().add(DeleteFavorite(favorite.id, userId)),
                      ),
                    );
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }
}