// presentation/screens/landpad_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:lab15/data/local/favorites_service.dart';
import 'package:lab15/data/models/landpad.dart';
import 'package:url_launcher/url_launcher.dart';

class LandpadDetailScreen extends StatefulWidget {
  final Landpad landpad;

  const LandpadDetailScreen({Key? key, required this.landpad}) : super(key: key);

  @override
  State<LandpadDetailScreen> createState() => _LandpadDetailScreenState();
}

class _LandpadDetailScreenState extends State<LandpadDetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = FavoritesService().isFavorite(widget.landpad.id);
  }

  void _toggleFavorite() async {
    await FavoritesService().toggleFavorite(widget.landpad);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> _openWikipedia() async {
    final uri = Uri.parse(widget.landpad.wikipedia);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Открываем в браузере
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Не удалось открыть ссылку")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ошибка при открытии ссылки")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.landpad.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.landpad.fullName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              "Статус: ${widget.landpad.status} • Тип: ${widget.landpad.type}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              "Местоположение: ${widget.landpad.locality}, ${widget.landpad.region}",
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.landpad.latitude != null && widget.landpad.longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Координаты: ${widget.landpad.latitude!.toStringAsFixed(4)}, ${widget.landpad.longitude!.toStringAsFixed(4)}",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              "Посадок: ${widget.landpad.landingSuccesses} успешных из ${widget.landpad.landingAttempts}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Text(
              "Описание:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.landpad.details.isEmpty ? "Нет описания" : widget.landpad.details,
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),
            if (widget.landpad.wikipedia.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _openWikipedia,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Открыть в Wikipedia"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}