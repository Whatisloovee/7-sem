// blocs/product/product_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../models/product.dart';
import '../../services/firestore_service.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  StreamSubscription? _subscription;
  final FirestoreService firestoreService;

  ProductBloc({FirestoreService? firestoreService})
      : firestoreService = firestoreService ?? FirestoreService(),
        super(ProductInitial()) {
    // ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);         // ← ДОБАВИТЬ!
    on<UpdateProduct>(_onUpdateProduct);   // ← ДОБАВИТЬ!
    on<DeleteProduct>(_onDeleteProduct);
    on<ProductsUpdated>(_onProductsUpdated);
    on<ProductsUpdatedError>(_onProductsUpdatedError);
    // ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    await firestoreService.seedDefaultProducts();

    _subscription?.cancel();
    _subscription = firestoreService.getProductsStream().listen(
          (products) {
        print('[ProductBloc] received products from service: ${products.map((p) => p.name).toList()}');
        add(ProductsUpdated(products));
      },
      onError: (e) => add(ProductsUpdatedError(e.toString())),
    );
  }

  void _onProductsUpdated(ProductsUpdated event, Emitter<ProductState> emit) {
    print('[ProductBloc] _onProductsUpdated -> ${event.products.map((p) => p.name).toList()}');
    emit(ProductLoaded(event.products));
  }

  void _onProductsUpdatedError(ProductsUpdatedError event, Emitter<ProductState> emit) {
    emit(ProductError(event.message));
  }

  // ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
  // Эти два метода у тебя были, но не были привязаны!
  Future<void> _onAddProduct(AddProduct event, Emitter<ProductState> emit) async {
    try {
      await firestoreService.addProduct(event.product);
      // После добавления — данные обновятся автоматически через стрим
    } catch (e) {
      emit(ProductError('Ошибка добавления: $e'));
    }
  }

  Future<void> _onUpdateProduct(UpdateProduct event, Emitter<ProductState> emit) async {
    try {
      await firestoreService.updateProduct(event.product);
      // Обновление тоже придёт через стрим
    } catch (e) {
      emit(ProductError('Ошибка обновления: $e'));
    }
  }
  // ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←

  Future<void> _onDeleteProduct(DeleteProduct event, Emitter<ProductState> emit) async {
    try {
      await firestoreService.deleteProduct(event.id);
    } catch (e) {
      emit(ProductError('Ошибка удаления: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}