// data/repositories/landpad_repository.dart
import 'package:dio/dio.dart';
import '../models/landpad.dart';

class LandpadRepository {
  final Dio dio;

  LandpadRepository(this.dio);

  Future<List<Landpad>> getLandpads() async {
    //5. Для запросов использовать пакеты http или dio.
    final response = await dio.get('https://api.spacexdata.com/v4/landpads');
    return (response.data as List)
        .map((json) => Landpad.fromJson(json))
        .toList();
  }
}