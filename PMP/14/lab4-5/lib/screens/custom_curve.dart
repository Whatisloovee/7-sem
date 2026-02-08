import 'package:flutter/material.dart';

// 2. Для одной из анимаций создать и назначить кастомную кривую(Curve) f(t) = 1 - (t - 1)⁴
class QuarticDecelerationCurve extends Curve {
  const QuarticDecelerationCurve();

  // Реализация функции кривой: f(t) = 1 - (1 - t)⁴.
  // В задании указана f(t) = 1 - (t - 1)⁴. Поскольку t находится в диапазоне [0, 1],
  // (t - 1)⁴ будет тем же, что и (1 - t)⁴, так как степень четная.
  // Использование 1 - (1 - t)⁴ дает кривую замедления, которая начинается быстро и заканчивается медленно (easeOutQuart).
  @override
  double transformInternal(double t) {
    // В Flutter 't' — это нормализованное время от 0.0 до 1.0.
    final double tMinus1 = t - 1.0;
    return 1.0 - tMinus1 * tMinus1 * tMinus1 * tMinus1;
  }
}