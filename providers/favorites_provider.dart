import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _movieKey = 'fav_movies';
  static const _actorKey = 'fav_actors';

  Set<String> _favoriteMovieIds = {};
  Set<String> _favoriteActorIds = {};

  Set<String> get favoriteMovieIds => _favoriteMovieIds;
  Set<String> get favoriteActorIds => _favoriteActorIds;

  FavoritesProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteMovieIds = Set<String>.from(prefs.getStringList(_movieKey) ?? []);
    _favoriteActorIds = Set<String>.from(prefs.getStringList(_actorKey) ?? []);
    notifyListeners();
  }

  Future<void> _saveMovies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_movieKey, _favoriteMovieIds.toList());
  }

  Future<void> _saveActors() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_actorKey, _favoriteActorIds.toList());
  }

  bool isMovieFavorite(String movieId) => _favoriteMovieIds.contains(movieId);
  bool isActorFavorite(String actorId) => _favoriteActorIds.contains(actorId);

  Future<void> toggleMovieFavorite(String movieId) async {
    if (_favoriteMovieIds.contains(movieId)) {
      _favoriteMovieIds.remove(movieId);
    } else {
      _favoriteMovieIds.add(movieId);
    }
    notifyListeners();
    await _saveMovies();
  }

  Future<void> toggleActorFavorite(String actorId) async {
    if (_favoriteActorIds.contains(actorId)) {
      _favoriteActorIds.remove(actorId);
    } else {
      _favoriteActorIds.add(actorId);
    }
    notifyListeners();
    await _saveActors();
  }
}
