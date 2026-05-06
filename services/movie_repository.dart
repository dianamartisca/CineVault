import '../models/actor.dart';
import '../models/movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> fetchMovies();
  Future<List<Movie>> fetchMoviesByGenre(String genreId);
  Future<Movie?> fetchMovieById(String id);
  Future<List<Actor>> fetchActors();
  Future<Actor?> fetchActorById(String id);
  Future<List<Movie>> searchMovies(String query);
}
