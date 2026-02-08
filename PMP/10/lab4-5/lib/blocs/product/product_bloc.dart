import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      var products = HiveService.getProducts();
      if (products.isEmpty) {
        await _addDefaultProducts();
        products = HiveService.getProducts();
      }
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _addDefaultProducts() async {
    await HiveService.addProduct(Product(
      id: '1',
      name: 'Aloe Vera',
      price: 60,
      image: 'https://www.cmp24.ru/images/prodacts/sourse/105628/105628848_aloe-vera-d12-h35-lerua-merlen.jpg',
    ));
    await HiveService.addProduct(Product(
      id: '2',
      name: 'Bonsai',
      price: 60,
      image: 'https://avatars.mds.yandex.net/i?id=367d93fe8bce347503f548aba6cd32b5e40f91e7-12635770-images-thumbs&n=13',
    ));
  }

  Future<void> _onAddProduct(AddProduct event, Emitter<ProductState> emit) async {
    await HiveService.addProduct(event.product);
    final products = HiveService.getProducts();
    emit(ProductLoaded(products));
  }

  Future<void> _onUpdateProduct(UpdateProduct event, Emitter<ProductState> emit) async {
    await HiveService.updateProduct(event.product);
    final products = HiveService.getProducts();
    emit(ProductLoaded(products));
  }

  Future<void> _onDeleteProduct(DeleteProduct event, Emitter<ProductState> emit) async {
    await HiveService.deleteProduct(event.id);
    final products = HiveService.getProducts();
    emit(ProductLoaded(products));
  }
}