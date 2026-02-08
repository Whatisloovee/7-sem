// screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onShowRegister;
  const LoginScreen({super.key, this.onShowRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный email')),
      );
      return;
    }

    context.read<AuthBloc>().add(PasswordResetRequested(email));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                key: const Key('emailField'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите email';
                  if (!value.contains('@')) return 'Некорректный email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('passwordField'),
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите пароль';
                  if (value.length < 6) return 'Минимум 6 символов';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Кнопка "Забыли пароль?"
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: const Text(
                    'Забыли пароль?',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Кнопка входа
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                  if (state is AuthPasswordResetSent) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Письмо для сброса пароля отправлено на ваш email!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      key: const Key('loginButton'),
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            SignInRequested(
                              _emailController.text.trim(),
                              _passwordController.text,
                            ),
                          );
                        }
                      },
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Войти', style: TextStyle(fontSize: 18)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

// ← НОВАЯ КНОПКА GOOGLE
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                  label: const Text('Войти через Google', style: TextStyle(fontSize: 18)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    context.read<AuthBloc>().add(GoogleSignInRequested());
                  },
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: widget.onShowRegister,
                child: const Text('Нет аккаунта? Зарегистрируйтесь'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}