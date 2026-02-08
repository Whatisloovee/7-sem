part of 'favorite_bloc.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoriteEvent {
  final String userId;
  const LoadFavorites(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ToggleFavorite extends FavoriteEvent {
  final String userId;
  final String productId;
  const ToggleFavorite(this.userId, this.productId);
  @override
  List<Object?> get props => [userId, productId];
}

class FavoritesUpdated extends FavoriteEvent {
  final List<Favorite> favorites;
  const FavoritesUpdated(this.favorites);
  @override
  List<Object?> get props => [favorites];
}

class FavoritesUpdatedError extends FavoriteEvent {
  final String message;
  const FavoritesUpdatedError(this.message);
  @override
  List<Object?> get props => [message];
}