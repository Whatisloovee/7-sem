part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  final Product product;
  const AddProduct(this.product);
  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final Product product;
  const UpdateProduct(this.product);
  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final String id;
  const DeleteProduct(this.id);
  @override
  List<Object?> get props => [id];
}

// ДОБАВИТЬ ЭТИ НОВЫЕ СОБЫТИЯ:
class ProductsUpdated extends ProductEvent {
  final List<Product> products;
  const ProductsUpdated(this.products);
  @override
  List<Object?> get props => [products];
}

class ProductsUpdatedError extends ProductEvent {
  final String message;
  const ProductsUpdatedError(this.message);
  @override
  List<Object?> get props => [message];
}