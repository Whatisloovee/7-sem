// presentation/screens/favorites_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lab15/data/local/favorites_service.dart';
import 'package:lab15/presentation/screens/landpad_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesService().getFavorites();

    return Scaffold(
      appBar: AppBar(title: Text("Избранные площадки")),
      body: favorites.isEmpty
          ? Center(child: Text("Нет избранных площадок"))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, i) {
          final pad = favorites[i];
          return ListTile(
            title: Text(pad.fullName),
            subtitle: Text(pad.locality),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LandpadDetailScreen(landpad: pad),
              ),
            ),
          );
        },
      ),
    );
  }
}