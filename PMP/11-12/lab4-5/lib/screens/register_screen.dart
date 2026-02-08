// screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onShowLogin;
  const RegisterScreen({super.key, this.onShowLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Поля ввода...
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Имя', border: OutlineInputBorder()), validator: (v) => v?.isEmpty ?? true ? 'Введите имя' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), validator: (v) => v?.isEmpty ?? true ? 'Введите email' : !v!.contains('@') ? 'Неверный email' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()), validator: (v) => v?.isEmpty ?? true ? 'Введите пароль' : v!.length < 6 ? 'Минимум 6 символов' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Подтвердите пароль', border: OutlineInputBorder()), validator: (v) => v != _passwordController.text ? 'Пароли не совпадают' : null),
              const SizedBox(height: 30),

              // Кнопка регистрации + логика успеха
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Регистрация успешна! Теперь войдите'), backgroundColor: Colors.green),
                    );
                    _nameController.clear();
                    _emailController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                    widget.onShowLogin?.call();
                  }
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(SignUpRequested(
                            _emailController.text.trim(),
                            _passwordController.text,
                            _nameController.text.trim(),
                          ));
                        }
                      },
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Зарегистрироваться', style: TextStyle(fontSize: 18)),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              TextButton(onPressed: widget.onShowLogin, child: const Text('Уже есть аккаунт? Войти')),
            ],
          ),
        ),
      ),
    );
  }
}