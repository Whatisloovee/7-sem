import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/favorite.dart';
import '../../services/hive_service.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<DeleteFavorite>(_onDeleteFavorite);
  }

  Future<void> _onLoadFavorites(
      LoadFavorites event, Emitter<FavoriteState> emit) async {
    emit(FavoriteLoading());
    try {
      final favorites = HiveService.getFavorites(event.userId);
      emit(FavoriteLoaded(favorites));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onAddFavorite(AddFavorite event, Emitter<FavoriteState> emit) async {
    await HiveService.addFavorite(event.favorite);
    final favorites = HiveService.getFavorites(event.favorite.userId);
    emit(FavoriteLoaded(favorites));
  }

  Future<void> _onDeleteFavorite(DeleteFavorite event, Emitter<FavoriteState> emit) async {
    await HiveService.deleteFavorite(event.id);
    final favorites = HiveService.getFavorites(event.userId);
    emit(FavoriteLoaded(favorites));
  }

  bool isProductFavorite(String productId, String userId, List<Favorite> favorites) {
    return favorites.any((f) => f.productId == productId && f.userId == userId);
  }

  String getFavoriteId(String productId, String userId) {
    return '${userId}_$productId';
  }
}