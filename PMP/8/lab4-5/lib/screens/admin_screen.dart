import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../services/hive_service.dart';

class AdminScreen extends StatefulWidget {
  final User currentUser;

  const AdminScreen({super.key, required this.currentUser});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

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
                          id: DateTime.now().toString(),
                          name: _nameController.text,
                          price: double.parse(_priceController.text),
                          image: _imageController.text,
                        );
                        HiveService.addProduct(product);
                        _nameController.clear();
                        _priceController.clear();
                        _imageController.clear();
                      }
                    },
                    child: const Text('Добавить товар'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<Box<Product>>(
                valueListenable: HiveService.productBox.listenable(),
                builder: (context, box, _) {
                  final products = box.values.toList();
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
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
                                _nameController.text = product.name;
                                _priceController.text = product.price.toString();
                                _imageController.text = product.image;
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Редактировать товар'),
                                    content: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: _nameController,
                                            decoration: const InputDecoration(labelText: 'Название'),
                                          ),
                                          TextFormField(
                                            controller: _priceController,
                                            decoration: const InputDecoration(labelText: 'Цена'),
                                            keyboardType: TextInputType.number,
                                          ),
                                          TextFormField(
                                            controller: _imageController,
                                            decoration: const InputDecoration(labelText: 'URL изображения'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            final updatedProduct = Product(
                                              id: product.id,
                                              name: _nameController.text,
                                              price: double.parse(_priceController.text),
                                              image: _imageController.text,
                                            );
                                            HiveService.updateProduct(updatedProduct);
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text('Сохранить'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                HiveService.deleteProduct(product.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}