// screens/discover_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab4_5/services/analytics_service.dart';
import 'package:lab4_5/services/remote_config_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../models/product.dart';
import '../services/online_status_service.dart';
import 'product_detail_screen.dart';
import 'favorites_screen.dart';
import 'admin_screen.dart';
import 'profile_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  bool _favoritesLoaded = false;
  Timer? _onlineTimer;
  Timer? _configRefreshTimer;

  @override
  void initState() {
    super.initState();

    // Запускаем обновление lastSeen каждые 30 секунд
    _onlineTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      OnlineStatusService.setOnline();
    });

    // ✅ РЕГИСТРИРУЕМ СЛУШАТЕЛЬ ИЗМЕНЕНИЙ КОНФИГА
    RemoteConfigService.addConfigListener(_onConfigChanged);

    // Обновляем Remote Config каждые 10 секунд
    _configRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _refreshRemoteConfig();
    });
  }

  // ✅ CALLBACK ДЛЯ ОБНОВЛЕНИЯ ВСЕГО UI ПРИ ИЗМЕНЕНИИ КОНФИГА
  void _onConfigChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshRemoteConfig() async {
    try {
      await RemoteConfigService.forceFetch();
    } catch (e) {
      print('Error refreshing remote config: $e');
    }
  }

  @override
  void dispose() {
    _onlineTimer?.cancel();
    _configRefreshTimer?.cancel();
    // ✅ УДАЛЯЕМ СЛУШАТЕЛЬ ПРИ УНИЧТОЖЕНИИ
    RemoteConfigService.removeConfigListener(_onConfigChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          _favoritesLoaded = false;
          _onlineTimer?.cancel();
          return const Scaffold(body: Center(child: Text('Не авторизован')));
        }

        final user = authState.user;

        if (!_favoritesLoaded) {
          context.read<FavoriteBloc>().add(LoadFavorites(user.id));
          _favoritesLoaded = true;
          OnlineStatusService.setOnline();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Discover'),
            backgroundColor: RemoteConfigService.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              if (user.role == 'admin' || user.role == 'manager')
                IconButton(
                  icon: const Icon(Icons.add_box),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())),
                ),

              // Иконка профиля
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ КНОПКА ДЛЯ ТЕСТИРОВАНИЯ ОБНОВЛЕНИЯ КОНФИГА
              if (user.role == 'admin' || user.role == 'manager')
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    await _refreshRemoteConfig();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Конфиг обновлен. Лайки: ${RemoteConfigService.isLikeEnabled ? "ВКЛ" : "ВЫКЛ"}'
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
            ],
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ✅ БАННЕР ТЕПЕРЬ АВТОМАТИЧЕСКИ ОБНОВЛЯЕТСЯ ЧЕРЕЗ setState
                if (!RemoteConfigService.isLikeEnabled) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Функция лайков временно отключена',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Поиск
                TextField(
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      AnalyticsService.logSearch(searchTerm: value.trim());
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Поиск растений...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Категории
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CategoryChip(icon: Icons.park, label: 'Зелёные'),
                    _CategoryChip(icon: Icons.local_florist, label: 'Цветы'),
                    _CategoryChip(icon: Icons.home, label: 'Для дома'),
                  ],
                ),
                const SizedBox(height: 20),

                // ✅ СПИСОК ТОВАРОВ ТЕПЕРЬ АВТОМАТИЧЕСКИ ОБНОВЛЯЕТСЯ
                Expanded(
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is! ProductLoaded) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return _ProductCard(product: product, userId: user.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: RemoteConfigService.primaryColor,
            unselectedItemColor: Colors.grey,
            currentIndex: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Корзина'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
            ],
            onTap: (index) {
              if (index == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
              } else if (index == 3) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              }
            },
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final String userId;

  const _ProductCard({required this.product, required this.userId});

  @override
  State<_ProductCard> createState() => __ProductCardState();
}

class __ProductCardState extends State<_ProductCard> {
  @override
  void initState() {
    super.initState();
    // ✅ РЕГИСТРИРУЕМ КАЖДУЮ КАРТОЧКУ КАК СЛУШАТЕЛЬ ИЗМЕНЕНИЙ
    RemoteConfigService.addConfigListener(_onConfigChanged);
  }

  @override
  void dispose() {
    // ✅ УДАЛЯЕМ СЛУШАТЕЛЬ ПРИ УНИЧТОЖЕНИИ КАРТОЧКИ
    RemoteConfigService.removeConfigListener(_onConfigChanged);
    super.dispose();
  }

  void _onConfigChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ИСПОЛЬЗУЕМ BlocConsumer ВМЕСТО BlocBuilder ДЛЯ ПРИНУДИТЕЛЬНОГО ОБНОВЛЕНИЯ
    return BlocConsumer<FavoriteBloc, FavoriteState>(
      listener: (context, state) {
        // Пустой listener, но он заставляет виджет реагировать на изменения FavoriteBloc
      },
      builder: (context, state) {
        final isFavorite = state is FavoriteLoaded &&
            state.favorites.any((f) => f.productId == widget.product.id);

        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductDetailScreen(product: widget.product))
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4)
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)
                      ),
                      child: Image.network(
                        widget.product.image,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error)
                        ),
                      ),
                    ),
                    // ✅ ТЕПЕРЬ КНОПКИ ЛАЙКОВ ИСЧЕЗНУТ/ПОЯВЯТСЯ МГНОВЕННО
                    if (RemoteConfigService.isLikeEnabled)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            context.read<FavoriteBloc>().add(
                                ToggleFavorite(widget.userId, widget.product.id)
                            );
                            if (isFavorite) {
                              AnalyticsService.logRemoveFromFavorites(
                                  productId: widget.product.id
                              );
                            } else {
                              AnalyticsService.logAddToFavorites(
                                productId: widget.product.id,
                                productName: widget.product.name,
                              );
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(height: 4),
                      Text(
                          '\$${widget.product.price}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green
                          )
                      ),
                    ],
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

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: RemoteConfigService.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: RemoteConfigService.primaryColor),
    );
  }
}