import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab4_5/services/analytics_service.dart';
import '../blocs/product/product_bloc.dart';
import '../models/product.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  String? _editingProductId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Управление товарами')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Название'),
                    validator: (v) => v!.isEmpty ? 'Введите название' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Цена'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Введите цену';
                      final price = double.tryParse(v);
                      if (price == null || price <= 0) return 'Введите корректную цену';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(labelText: 'URL изображения'),
                    validator: (v) {
                      if (v!.isEmpty) return 'Введите URL';
                      if (!v.startsWith('http')) return 'Введите корректный URL';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final product = Product(
                          id: _editingProductId ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _nameController.text,
                          price: double.parse(_priceController.text),
                          image: _imageController.text,
                        );

                        if (_editingProductId != null) {
                          context.read<ProductBloc>().add(UpdateProduct(product));
                        } else {
                          context.read<ProductBloc>().add(AddProduct(product));
                          // ← Логируем создание товара
                          await AnalyticsService.logAdminProductAdded(productName: product.name);
                        }
                        _resetForm();
                      }
                    },
                    child: Text(_editingProductId != null ? 'Обновить' : 'Добавить'),
                  ),
                  if (_editingProductId != null)
                    TextButton(
                        onPressed: _resetForm,
                        child: const Text('Отменить')
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductLoaded) {
                    final products = state.products;
                    if (products.isEmpty) {
                      return const Center(child: Text('Нет товаров'));
                    }
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Image.network(
                              product.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                            ),
                            title: Text(product.name),
                            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      _editingProductId = product.id;
                                      _nameController.text = product.name;
                                      _priceController.text = product.price.toString();
                                      _imageController.text = product.image;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Удалить товар?'),
                                        content: Text('Вы уверены, что хотите удалить ${product.name}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Отмена'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              context.read<ProductBloc>().add(DeleteProduct(product.id));
                                              AnalyticsService.logAdminProductDeleted(productId: product.id);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Удалить'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (state is ProductError) {
                    return Center(child: Text('Ошибка: ${state.message}'));
                  }
                  return const Center(child: Text('Загрузите товары'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _editingProductId = null;
      _nameController.clear();
      _priceController.clear();
      _imageController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}