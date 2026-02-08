import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user/user_bloc.dart';
import 'discover_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<UserBloc>().add(InitializeUsers());

    return Scaffold(
      appBar: AppBar(title: const Text('Выбор пользователя')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoaded && state.users.isNotEmpty) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.role),
                  onTap: () {
                    context.read<UserBloc>().add(SelectUser(user));
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DiscoverScreen()));
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}