// screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  String? _editingProductId;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

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
                    validator: (value) => value!.isEmpty ? 'Введите название' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Цена'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Введите цену' : null,
                  ),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(labelText: 'URL изображения'),
                    validator: (value) => value!.isEmpty ? 'Введите URL' : null,
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
                          productProvider.updateProduct(product);
                        } else {
                          productProvider.addProduct(product);
                        }

                        _resetForm();
                      }
                    },
                    child: Text(_editingProductId != null ? 'Обновить товар' : 'Добавить товар'),
                  ),
                  if (_editingProductId != null)
                    TextButton(
                      onPressed: _resetForm,
                      child: const Text('Отменить редактирование'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
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
                            _editingProductId = product.id;
                            _nameController.text = product.name;
                            _priceController.text = product.price.toString();
                            _imageController.text = product.image;
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            productProvider.deleteProduct(product.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    _editingProductId = null;
    _nameController.clear();
    _priceController.clear();
    _imageController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}