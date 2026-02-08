// screens/user_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/product_provider.dart';
import 'discover_screen.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final productProvider = context.read<ProductProvider>();

      userProvider.initializeUsers();
      productProvider.initializeProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Выбор пользователя')),
      body: userProvider.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: userProvider.users.length,
        itemBuilder: (context, index) {
          final user = userProvider.users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text(user.role),
            onTap: () {
              userProvider.setCurrentUser(user);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiscoverScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}