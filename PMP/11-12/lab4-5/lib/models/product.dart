import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String image;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId, // Используем ID документа Firestore
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      image: map['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
    };
  }

  @override
  List<Object?> get props => [id, name, price, image];
}