import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:lab15/data/local/favorites_service.dart';
import 'package:lab15/data/repositories/landpad_repository.dart';
import 'package:lab15/presentation/bloc/landpad_bloc.dart';
import 'package:lab15/presentation/screens/landpads_list_screen.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.deleteFromDisk();
  await FavoritesService().init();
//5. Для запросов использовать пакеты http или dio.
  final dio = Dio();
  GetIt.I.registerSingleton<LandpadRepository>(LandpadRepository(dio));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceX Landpads',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: BlocProvider(
        create: (_) => LandpadBloc(GetIt.I<LandpadRepository>())..add(LoadLandpads()),
        child: LandpadsListScreen(),
      ),
    );
  }
}