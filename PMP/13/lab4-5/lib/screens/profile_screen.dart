import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab4_5/services/remote_config_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../services/online_status_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: RemoteConfigService.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Аватар + онлайн-статус
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green[100],
                      child: Text(
                        (user.name != null && user.name.isNotEmpty) ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: StreamBuilder<Map<String, dynamic>?>(
                        stream: OnlineStatusService.getStatusStream(user.id),
                        builder: (context, snapshot) {
                          final online = snapshot.data?['online'] ?? false;
                          return Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: online ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StreamBuilder<Map<String, dynamic>?>(
                  stream: OnlineStatusService.getStatusStream(user.id),
                  builder: (context, snapshot) {
                    final online = snapshot.data?['online'] ?? false;
                    final lastSeen = snapshot.data?['lastSeen'] as DateTime?;
                    return Text(
                      online ? 'Онлайн' : _formatLastSeen(lastSeen),
                      style: TextStyle(
                        fontSize: 16,
                        color: online ? Colors.green : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                _InfoCard(icon: Icons.person, label: 'Имя', value: (user.name == null || user.name.isEmpty) ? 'Не указано' : user.name),
                _InfoCard(icon: Icons.email, label: 'Email', value: user.email ?? ''),
                _InfoCard(
                  icon: Icons.admin_panel_settings,
                  label: 'Роль',
                  value: user.role == 'admin' ? 'Администратор' : user.role == 'manager' ? 'Менеджер' : 'Пользователь',
                  valueColor: user.role == 'admin' ? Colors.red : user.role == 'manager' ? Colors.orange : Colors.green,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      OnlineStatusService.setOffline();
                      context.read<AuthBloc>().add(SignOutRequested());
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Выйти из аккаунта'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RemoteConfigService.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatLastSeen(DateTime? date) {
    if (date == null) return 'Был(а) давно';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Был(а) только что';
    if (diff.inMinutes < 60) return 'Был(а) ${diff.inMinutes} мин. назад';
    if (diff.inHours < 24) return 'Был(а) ${diff.inHours} ч. назад';
    if (diff.inDays < 7) return 'Был(а) ${diff.inDays} д. назад';
    return 'Был(а) ${date.day}.${date.month} в ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCard({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, color: valueColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}