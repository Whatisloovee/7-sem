import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:lab4_5/blocs/favorite/favorite_bloc.dart';
import 'package:lab4_5/models/favorite.dart';
import '../mocks.mocks.dart';

void main() {
  group('FavoriteBloc', () {
    late MockFirestoreService mockFirestoreService;
    late StreamController<List<Favorite>> streamController;

    setUp(() {
      mockFirestoreService = MockFirestoreService();
      streamController = StreamController<List<Favorite>>();
    });

    tearDown(() {
      streamController.close();
    });

    // Test 4: Toggling favorite (add when not favorited)
    blocTest<FavoriteBloc, FavoriteState>(
      'calls addToFavorites when ToggleFavorite is added and product is not favorited',
      build: () {
        // Mock addToFavorites to succeed
        when(mockFirestoreService.addToFavorites(any, any)).thenAnswer((_) async => 'fav_id');
        return FavoriteBloc(firestoreService: mockFirestoreService);
      },
      // Seed initial state with no favorites
      seed: () => FavoriteLoaded([]),
      act: (bloc) => bloc.add(ToggleFavorite('user1', 'prod1')),
      expect: () => [],  // No direct state; update via stream
      verify: (_) {
        verify(mockFirestoreService.addToFavorites('user1', 'prod1')).called(1);
      },
    );
  });
}