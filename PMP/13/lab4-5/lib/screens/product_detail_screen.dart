// screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab4_5/services/analytics_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logProductView(
        productId: product.id,
        productName: product.name,
      );
    });
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Если не авторизован — показываем заглушку
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text(
                'Войдите в аккаунт, чтобы добавлять в избранное',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final user = authState.user;

        // Загружаем избранное только при переходе в авторизованное состояние
        return BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, current) =>
          prev is! AuthAuthenticated && current is AuthAuthenticated,
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.read<FavoriteBloc>().add(LoadFavorites(state.user.id));
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF94a561),
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.share, color: Colors.white),
                            const SizedBox(width: 16),
                            BlocBuilder<FavoriteBloc, FavoriteState>(
                              builder: (context, state) {
                                final isFavorite = state is FavoriteLoaded &&
                                    state.favorites.any((f) => f.productId == product.id);

                                return IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.white,
                                  ),
                                  onPressed: () {
                                    context.read<FavoriteBloc>().add(
                                      ToggleFavorite(user.id, product.id),
                                    );
                                    if (isFavorite) {
                                      AnalyticsService.logRemoveFromFavorites(productId: product.id);
                                    } else {
                                      AnalyticsService.logAddToFavorites(
                                        productId: product.id,
                                        productName: product.name,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Фото товара
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(product.image, fit: BoxFit.cover),
                      ),
                    ),
                  ),

                  // Нижняя часть
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          const Text(
                            'Fertilize sparingly (no more than once a month), and only in the spring and summer with a balanced houseplant formula mixed at ½ strength.',
                            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF41612c),
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: Text('Checkout \$${product.price}', style: const TextStyle(fontSize: 18)),
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
          ),
        );
      },
    );
  }
}