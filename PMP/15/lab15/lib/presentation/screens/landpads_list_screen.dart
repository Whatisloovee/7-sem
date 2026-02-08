// presentation/screens/landpads_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lab15/presentation/screens/favorites_screen.dart';
import '../../data/local/favorites_service.dart';
import '../bloc/landpad_bloc.dart';
import 'landpad_detail_screen.dart';

class LandpadsListScreen extends StatefulWidget {
  @override
  State<LandpadsListScreen> createState() => _LandpadsListScreenState();
}

class _LandpadsListScreenState extends State<LandpadsListScreen> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() => _isOnline = result != ConnectivityResult.none);
      if (_isOnline) {
        context.read<LandpadBloc>().add(LoadLandpads());
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() => _isOnline = result != ConnectivityResult.none);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SpaceX Landpads'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesScreen(),
              ),
            ),
          ),
        ],
      ),
      //7. При отсутствии доступа к интернету показывать кнопку для перехода к просмотру закешированных данные с пометкой о недоступности сервиса.
      body: !_isOnline
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

          ],
        ),
      )
          : BlocBuilder<LandpadBloc, LandpadState>(
        builder: (context, state) {
          //2. Индикатор загрузки
          if (state is LandpadLoading) {
            return Center(child: CircularProgressIndicator());
          }
          //4. При ошибке сети или сервера должно отображаться сообщение об ошибке и кнопка для повтора запроса.
          if (state is LandpadError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Нет подключения к интернету"),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FavoritesScreen()),
                      ),
                      child: Text("Перейти в Избранное"),
                    ),
              ]
                  ),
                  Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<LandpadBloc>().add(LoadLandpads()),
                    child: Text("Повторить"),
                  ),
              ]
          ),
                ],
              ),
            );
          }
          if (state is LandpadLoaded) {
            return ListView.builder(
              itemCount: state.landpads.length,
              itemBuilder: (context, index) {
                final pad = state.landpads[index];
                final isFav = FavoritesService().isFavorite(pad.id);
                return ListTile(
                  //3. Список, который отображается на первой странице должен содержать минимум два поля (но не все для реализации страницы подробно)
                  title: Text(pad.fullName),
                  subtitle: Text("${pad.locality}, ${pad.region}"),
                  trailing: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : null,
                    ),
                    onPressed: () {
                      //6. Должна быть реализована возможность кешировать (сохранять) выбранные элементы (как пример избранное или понравившееся для шуток) локально как с использованием hive или sqllite.
                      FavoritesService().toggleFavorite(pad);
                      setState(() {}); // обновляем иконку
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LandpadDetailScreen(landpad: pad),
                      ),
                    );
                  },
                );
              },
            );
          }
          return Center(child: Text("Нажмите для загрузки"));
        },
      ),
      floatingActionButton: _isOnline
          ? FloatingActionButton(
        onPressed: () =>
            context.read<LandpadBloc>().add(LoadLandpads()),
        child: Icon(Icons.refresh),
      )
          : null,
    );
  }
}