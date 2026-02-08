import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                    validator: (v) => v!.isEmpty ? 'Введите цену' : null,
                  ),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(labelText: 'URL изображения'),
                    validator: (v) => v!.isEmpty ? 'Введите URL' : null,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final product = Product(
                          id: _editingProductId ?? DateTime.now().toString(),
                          name: _nameController.text,
                          price: double.parse(_priceController.text),
                          image: _imageController.text,
                        );
                        if (_editingProductId != null) {
                          context.read<ProductBloc>().add(UpdateProduct(product));
                        } else {
                          context.read<ProductBloc>().add(AddProduct(product));
                        }
                        _resetForm();
                      }
                    },
                    child: Text(_editingProductId != null ? 'Обновить' : 'Добавить'),
                  ),
                  if (_editingProductId != null)
                    TextButton(onPressed: _resetForm, child: const Text('Отменить')),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductLoaded) {
                    return ListView.builder(
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return ListTile(
                          leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
                          title: Text(product.name),
                          subtitle: Text('\$${product.price}'),
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
                                  context.read<ProductBloc>().add(DeleteProduct(product.id));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Ошибка загрузки'));
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