import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../models/favorite.dart';
import '../../services/firestore_service.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FirestoreService firestoreService;
  StreamSubscription? _subscription;
  String? _currentUserId;

  FavoriteBloc({FirestoreService? firestoreService})
      : firestoreService = firestoreService ?? FirestoreService(),
        super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<FavoritesUpdated>(_onFavoritesUpdated);
    on<FavoritesUpdatedError>(_onFavoritesUpdatedError);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoriteState> emit) async {
    if (_currentUserId == event.userId && state is FavoriteLoaded) return;

    emit(FavoriteLoading());
    _currentUserId = event.userId;

    _subscription?.cancel();
    _subscription = firestoreService.getFavoritesStream(event.userId).listen(
          (favorites) => add(FavoritesUpdated(favorites)),
      onError: (e) => add(FavoritesUpdatedError(e.toString())),
    );
  }

  void _onFavoritesUpdated(FavoritesUpdated event, Emitter<FavoriteState> emit) {
    emit(FavoriteLoaded(event.favorites));
  }

  void _onFavoritesUpdatedError(FavoritesUpdatedError event, Emitter<FavoriteState> emit) {
    emit(FavoriteError(event.message));
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FavoriteState> emit) async {
    final currentFavorites = state is FavoriteLoaded ? (state as FavoriteLoaded).favorites : <Favorite>[];

    final isFavorited = currentFavorites.any((f) => f.productId == event.productId);

    if (isFavorited) {
      final favId = currentFavorites.firstWhere((f) => f.productId == event.productId).id;
      await firestoreService.removeFromFavorites(favId);
    } else {
      await firestoreService.addToFavorites(event.userId, event.productId);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}