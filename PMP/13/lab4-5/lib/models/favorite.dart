import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  final String id;
  final String userId;
  final String productId;

  const Favorite({
    required this.id,
    required this.userId,
    required this.productId,
  });

  factory Favorite.fromMap(Map<String, dynamic> map, String docId) {
    return Favorite(
      id: docId, // Используем ID документа Firestore
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
    };
  }

  @override
  List<Object?> get props => [id, userId, productId];
}