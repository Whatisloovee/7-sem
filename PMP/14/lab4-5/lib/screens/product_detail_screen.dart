import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab4_5/screens/custom_curve.dart';
import '../blocs/user/user_bloc.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Искусственное состояние для демонстрации анимации
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserBloc>().state is UserLoaded
        ? (context.read<UserBloc>().state as UserLoaded).currentUser
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF94a561),
      body: SafeArea(
        child: Column(
          children: [
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
                    children: [
                      const Icon(Icons.share, color: Colors.white, size: 24),
                      const SizedBox(width: 16),
                      // 1. Implicit анимация: изменение цвета и размера иконки (3)
                      // 2. Для одной из анимаций создать и назначить кастомную кривую(Curve) f(t) = 1 - (t - 1)⁴
                      // 3. Добавить действие которое будет запущено по окончанию анимации (onEnd:.....)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLiked = !_isLiked;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 700),
                          curve: const QuarticDecelerationCurve(),
                          padding: EdgeInsets.all(_isLiked ? 12 : 8),
                          decoration: BoxDecoration(
                            color: _isLiked ? Colors.red.withOpacity(0.2) : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          onEnd: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isLiked
                                    ? 'Товар добавлен в избранное!'
                                    : 'Товар удалён из избранного'),
                                duration: const Duration(milliseconds: 800),
                                backgroundColor: _isLiked ? Colors.green : Colors.grey[700],
                              ),
                            );
                          },
                          child: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.redAccent : Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 4. Продемонстрировать несколько анимаций с использованием TweenAnimationBuilder
            // Анимация масштаба для изображения товара
            Expanded(
              flex: 2,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(widget.product.image, fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const Text(
                          'Lidah Buaya',
                          style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fertilize sparingly (no more than once a month), and only in the spring and summer with a balanced houseplant formula mixed at ½ strength.',
                      style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          SizedBox(width: 8),
                          _CareCard(icon: Icons.water_drop, label: 'Drained', subtitle: 'Watering'),
                          _CareCard(icon: Icons.wb_sunny, label: 'Full Sun', subtitle: 'Sunlight'),
                          _CareCard(icon: Icons.straighten, label: '30 x 50 cm', subtitle: 'Size'),
                          _CareCard(icon: Icons.thermostat, label: '13-27°C', subtitle: 'Temperature'),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(7)),
                              child: IconButton(padding: EdgeInsets.zero, iconSize: 18, icon: const Icon(Icons.remove), onPressed: () {}),
                            ),
                            const SizedBox(width: 10),
                            const Text('1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                            const SizedBox(width: 10),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(7)),
                              child: IconButton(padding: EdgeInsets.zero, iconSize: 18, icon: const Icon(Icons.add), onPressed: () {}),
                            ),
                          ],
                        ),
                        // 4. Продемонстрировать несколько анимаций с использованием TweenAnimationBuilder
                        // Анимация сдвига и цвета для кнопки "Checkout"
                        TweenAnimationBuilder<Offset>(
                          tween: Tween<Offset>(begin: const Offset(100, 0), end: const Offset(0, 0)),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (context, offset, child) {
                            return Transform.translate(
                              offset: offset,
                              child: child,
                            );
                          },
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF41612c),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'Checkout \$${widget.product.price}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

class _CareCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _CareCard({required this.icon, required this.label, required this.subtitle});

  @override
  State<_CareCard> createState() => _CareCardState();
}

class _CareCardState extends State<_CareCard> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isActive = !_isActive; // Переключаем состояние при каждом нажатии
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        transform: Matrix4.identity()..scale(_isActive ? 1.05 : 1.0),
        decoration: BoxDecoration(
          color: _isActive ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isActive ? 0.15 : 0.05),
              blurRadius: _isActive ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: _isActive ? Colors.green[800] : Colors.green[600],
              size: 28,
            ),
            const SizedBox(height: 15),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isActive ? Colors.green[800] : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
