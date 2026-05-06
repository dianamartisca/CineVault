import 'package:flutter/foundation.dart';
import '../models/actor.dart';
import '../models/movie.dart';
import '../services/movie_repository.dart';

enum LoadState { idle, loading, loaded, error }

class MoviesProvider extends ChangeNotifier {
  final MovieRepository repository;

  MoviesProvider({required this.repository});

  List<Movie> _movies = [];
  List<Actor> _actors = [];
  LoadState _state = LoadState.idle;
  String _errorMessage = '';
  String _searchQuery = '';

  List<Movie> get movies => _filteredMovies;
  List<Actor> get actors => _actors;
  LoadState get state => _state;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<Movie> get _filteredMovies {
    if (_searchQuery.isEmpty) return _movies;
    final q = _searchQuery.toLowerCase();
    return _movies.where((m) {
      return m.title.toLowerCase().contains(q) ||
          m.director.toLowerCase().contains(q) ||
          m.genres.any((g) => g.contains(q)) ||
          m.producers.any((p) => p.toLowerCase().contains(q)) ||
          m.actors.any((a) => a.name.toLowerCase().contains(q));
    }).toList();
  }

  List<Movie> moviesByGenre(String genreId) =>
      _movies.where((m) =>
        m.genres.any((g) => g.toLowerCase() == genreId.toLowerCase())).toList();

  List<Movie> moviesForActor(String actorId) =>
      _movies.where((m) => m.actors.any((a) => a.id == actorId)).toList();

  List<Movie> favoriteMovies(Set<String> ids) =>
      _movies.where((m) => ids.contains(m.id)).toList();

  List<Actor> favoriteActors(Set<String> ids) =>
      _actors.where((a) => ids.contains(a.id)).toList();

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadAll() async {
    _state = LoadState.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        repository.fetchMovies(),
        repository.fetchActors(),
      ]);
      _movies = results[0] as List<Movie>;
      _actors = results[1] as List<Actor>;

      final Map<String, Actor> actorMap = {for (var a in _actors) a.id: a};
      for (final m in _movies) {
        for (final a in m.actors) {
          if (!actorMap.containsKey(a.id)) actorMap[a.id] = a;
        }
      }
      _actors = actorMap.values.toList();
      _state = LoadState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }
}
