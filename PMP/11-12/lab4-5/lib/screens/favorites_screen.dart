// screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/product/product_bloc.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Войдите в аккаунт, чтобы увидеть избранное',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final userId = authState.user.id;

        // ГРУЗИМ ИЗБРАННОЕ ТОЛЬКО ПРИ ПЕРЕХОДЕ ИЗ НЕАВТОРИЗОВАННОГО В АВТОРИЗОВАННОЕ СОСТОЯНИЕ
        return BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, current) =>
          prev is! AuthAuthenticated && current is AuthAuthenticated,
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.read<FavoriteBloc>().add(LoadFavorites(state.user.id));
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Избранное'),
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            body: BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
                if (state is FavoriteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FavoriteError) {
                  return Center(child: Text('Ошибка: ${state.message}'));
                }

                if (state is! FavoriteLoaded || state.favorites.isEmpty) {
                  return const Center(
                    child: Text(
                      'У вас пока нет избранных товаров',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final favorites = state.favorites;
                final products = context.select<ProductBloc, List<Product>>(
                      (bloc) => bloc.state is ProductLoaded
                      ? (bloc.state as ProductLoaded).products
                      : <Product>[],
                );

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final fav = favorites[index];
                    final product = products.firstWhere(
                          (p) => p.id == fav.productId,
                      orElse: () => Product(
                        id: '',
                        name: 'Товар удалён',
                        price: 0,
                        image: '',
                      ),
                    );

                    if (product.id.isEmpty) return const SizedBox.shrink();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                          ),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('\$${product.price}', style: const TextStyle(color: Colors.green)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<FavoriteBloc>().add(ToggleFavorite(userId, product.id));
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}