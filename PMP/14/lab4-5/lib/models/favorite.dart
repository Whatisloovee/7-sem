import 'package:hive/hive.dart';

part 'favorite.g.dart';

@HiveType(typeId: 2)
class Favorite {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String productId;

  Favorite({required this.id, required this.userId, required this.productId});
}