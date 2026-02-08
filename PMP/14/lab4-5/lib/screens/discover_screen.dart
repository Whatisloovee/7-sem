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
import '../screens/custom_curve.dart'; // Импортируем кастомную кривую

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
                  // 4. Продемонстрировать несколько анимаций с использованием TweenAnimationBuilder
                  // Анимация прозрачности и сдвига для поля поиска
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: TextField(
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
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _CategoryButton(icon: Icons.park_outlined, label: 'Green Plants', index: 0),
                      _CategoryButton(icon: Icons.local_florist_outlined, label: 'Flowers', index: 1),
                      _CategoryButton(icon: Icons.eco_outlined, label: 'Indoor Plant', index: 2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 5. Создать и продемонстрировать работу минимум двух явных (Explicit) анимаций
                  // Явная анимация для баннера
                  const AnimatedBanner(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, productState) {
                        if (productState is! ProductLoaded) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // 6. Создать и продемонстрировать работу минимум двух ступенчатых анимаций (Stagerred)
                        // Ступенчатая анимация для списка товаров (по 2 товара в строке)
                        return StaggeredProductsGrid(
                            products: productState.products,
                            currentUser: currentUser
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

// 1. Продемонстрировать работу минимум трёх Implicit анимаций
class _CategoryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  const _CategoryButton({required this.icon, required this.label, required this.index});

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
        child: AnimatedContainer( // 1. Implicit анимация: цвет фона, радиус скругления, тень, размер
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isSelected ? 90 : 80, // Анимация высоты (1)
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF94a561).withOpacity(0.7) : Colors.white, // Анимация цвета (2)
            borderRadius: BorderRadius.circular(isSelected ? 18 : 12),
            boxShadow: [
              BoxShadow(
                color: isSelected ? Colors.green.withOpacity(1) : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? 20 : 2, // Анимация тени (3)
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: isSelected ? Colors.white : Colors.green, size: 30),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500
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


// Обновленный виджет карточки, который поддерживает внутреннюю ступенчатую анимацию.
class _ProductCard extends StatelessWidget {
  final Product product;
  final User currentUser;
  // Параметры для реализации ступенчатой анимации:
  final AnimationController controller; // Общий контроллер для всех ступеней
  final Interval mainAnimationInterval; // Интервал, в который должна уместиться анимация карточки

  const _ProductCard({
    super.key,
    required this.product,
    required this.currentUser,
    required this.controller,
    required this.mainAnimationInterval,
  });

  // Вспомогательная функция для создания вложенной анимации (шага)
  Animation<double> _buildAnimation(double begin, double end, Interval localInterval) {
    // Вычисляем фактический интервал, вложенный в основной интервал (mainAnimationInterval)
    final double mainDuration = mainAnimationInterval.end - mainAnimationInterval.begin;

    final double actualBegin = mainAnimationInterval.begin + localInterval.begin * mainDuration;
    final double actualEnd = mainAnimationInterval.begin + localInterval.end * mainDuration;

    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          actualBegin,
          actualEnd,
          curve: Curves.easeOutCubic, // Используем красивую кривую для плавности
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- Вторая ступенчатая анимация (5 шагов внутри ОДНОЙ карточки) ---

    // Шаг 1: Анимация масштаба всего контейнера (быстрый "выстрел" в начале интервала)
    final containerScaleAnimation = _buildAnimation(0.5, 1.0, const Interval(0.0, 0.4, curve: Curves.elasticOut));

    // Шаг 2: Анимация сдвига изображения (снизу вверх)
    final imageSlideAnimation = _buildAnimation(0.0, 1.0, const Interval(0.1, 0.6));

    // Шаг 3: Анимация иконки избранного (появляется после изображения)
    final favoriteIconAnimation = _buildAnimation(0.0, 1.0, const Interval(0.4, 0.7));

    // Шаг 4: Анимация имени товара (появляется после иконки)
    final nameFadeAnimation = _buildAnimation(0.0, 1.0, const Interval(0.6, 0.8));

    // Шаг 5: Анимация цены (последний элемент)
    final priceFadeAnimation = _buildAnimation(0.0, 1.0, const Interval(0.7, 1.0));


    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        final isFavorite = favoriteState is FavoriteLoaded &&
            context.read<FavoriteBloc>().isProductFavorite(product.id, currentUser.id, favoriteState.favorites);

        // Применяем Шаг 1 (масштаб) ко всей карточке
        return ScaleTransition(
          scale: containerScaleAnimation,
          child: GestureDetector(
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
                  // Блок изображения
                  Expanded(
                    flex: 3,
                    // Применяем Шаг 2 (сдвиг) к изображению
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - imageSlideAnimation.value)),
                      child: Opacity(
                        opacity: imageSlideAnimation.value,
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
                              // Применяем Шаг 3 (прозрачность иконки)
                              child: FadeTransition(
                                opacity: favoriteIconAnimation,
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Блок текста
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Применяем Шаг 4 (прозрачность имени)
                          FadeTransition(
                            opacity: nameFadeAnimation,
                            child: Text(
                              product.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Применяем Шаг 5 (прозрачность цены)
                          FadeTransition(
                            opacity: priceFadeAnimation,
                            child: Text('\$${product.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

// 6. Создать и продемонстрировать работу минимум двух ступенчатых анимаций (Stagerred)
class StaggeredProductsGrid extends StatefulWidget {
  final List<Product> products;
  final User currentUser;

  const StaggeredProductsGrid({super.key, required this.products, required this.currentUser});

  @override
  State<StaggeredProductsGrid> createState() => _StaggeredProductsGridState();
}

class _StaggeredProductsGridState extends State<StaggeredProductsGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Вторая ступенчатая анимация для фона (например, изменение цвета)
    final backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.green[500],
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1, curve: Curves.easeInQuad),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          color: backgroundAnimation.value,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: widget.products.length,
            itemBuilder: (context, index) {
              final product = widget.products[index];
              // 5 шагов/ступеней (для каждого продукта в пределах первых 5)
              final delay = 0.1 * (index / 2); // Задержка для каждого ряда
              final interval = Interval(delay, delay + 0.5, curve: Curves.easeOut);

              final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: interval,
                ),
              );

              return _ProductCard(
                product: product,
                currentUser: widget.currentUser,
                mainAnimationInterval: interval, // Передаем ИНТЕРВАЛ для внешнего шага
                controller: _controller, // Передаем КОНТРОЛЛЕР для внутренних шагов
              );
            },
          ),
        );
      },
    );
  }
}

// 5. Создать и продемонстрировать работу минимум двух явных (Explicit) анимаций
// Явная анимация для баннера (вращение)
class AnimatedBanner extends StatefulWidget {
  const AnimatedBanner({super.key});

  @override
  State<AnimatedBanner> createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<AnimatedBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation; // Явная анимация: Вращение (1)
  late Animation<Offset> _slideAnimation;    // Явная анимация: Сдвиг текста (2)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(); // Повторяем анимацию

    _rotationAnimation = Tween<double>(begin: 0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.05, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine, // Использование синусоидальной кривой для эффекта "дыхания"
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFdcde9f),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: SlideTransition( // Применяем явную анимацию сдвига к тексту
              position: _slideAnimation,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Get', style: TextStyle(fontSize: 14)),
                  Text('20% off', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  Text('For Today', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          RotationTransition( // Применяем явную анимацию вращения к картинкам
            turns: _rotationAnimation,
            child: SizedBox(
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
          ),
        ],
      ),
    );
  }
}