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

class AddFavorite extends FavoriteEvent {
  final Favorite favorite;
  const AddFavorite(this.favorite);
  @override
  List<Object?> get props => [favorite];
}

class DeleteFavorite extends FavoriteEvent {
  final String id;
  final String userId;
  const DeleteFavorite(this.id, this.userId);
  @override
  List<Object?> get props => [id, userId];
}