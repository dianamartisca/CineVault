import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/actor.dart';
import '../models/movie.dart';
import 'movie_repository.dart';

class TMDBMovieRepository implements MovieRepository {
  final String apiKey;
  final String _baseUrl = 'api.themoviedb.org';
  final String _imageBase = 'https://image.tmdb.org/t/p/w500';
  static const int _popularPagesToFetch = 3;

  TMDBMovieRepository({required String apiKey}) : apiKey = apiKey;

  Uri _buildUri(String path, [Map<String, String>? params]) {
    final all = <String, String>{'api_key': apiKey, 'language': 'en-US'};
    if (params != null) all.addAll(params);
    return Uri.https(_baseUrl, path, all);
  }

  String _image(String? path) => path == null ? '' : '$_imageBase$path';

  @override
  Future<List<Movie>> fetchMovies() async {
    final ids = <String>{};

    for (var page = 1; page <= _popularPagesToFetch; page++) {
      final uri = _buildUri('/3/movie/popular', {'page': '$page'});
      final res = await http.get(uri);
      if (res.statusCode != 200) throw Exception('TMDB fetch failed');
      final body = json.decode(res.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>;
      for (final r in results) {
        final id = (r as Map<String, dynamic>)['id'].toString();
        ids.add(id);
      }
    }


    final movies = <Movie>[];
    for (final id in ids) {
      final full = await fetchMovieById(id);
      if (full != null) movies.add(full);
    }
    return movies;
  }

  Movie _movieFromSummary(Map<String, dynamic> json) {
    final poster = _image(json['poster_path'] as String?);
    final backdrop = _image(json['backdrop_path'] as String?);
    final releaseDate = json['release_date'] as String?;
    final year = (releaseDate != null && releaseDate.isNotEmpty)
        ? int.tryParse(releaseDate.split('-').first) ?? 0
        : 0;

    return Movie(
      id: (json['id']).toString(),
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      plot: json['overview'] as String? ?? '',
      posterUrl: poster,
      backdropUrl: backdrop,
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      year: year,
      durationMinutes: 0,
      genres: [],
      actors: const [],
      producers: const [],
      director: '',
    );
  }

  @override
  Future<List<Movie>> fetchMoviesByGenre(String genreId) async {
    final params = <String, String>{'page': '1'};
    if (int.tryParse(genreId) != null) params['with_genres'] = genreId;
    final uri = _buildUri('/3/discover/movie', params);
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('TMDB fetch failed');
    final body = json.decode(res.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;
    final movies = <Movie>[];
    for (final r in results) {
      final id = (r as Map<String, dynamic>)['id'].toString();
      final full = await fetchMovieById(id);
      if (full != null) movies.add(full);
    }
    return movies;
  }

  @override
  Future<Movie?> fetchMovieById(String id) async {
    final uri = _buildUri('/3/movie/$id', {'append_to_response': 'credits'});
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    final poster = _image(jsonBody['poster_path'] as String?);
    final backdrop = _image(jsonBody['backdrop_path'] as String?);

    final releaseDate = jsonBody['release_date'] as String?;
    final year = (releaseDate != null && releaseDate.isNotEmpty)
        ? int.tryParse(releaseDate.split('-').first) ?? 0
        : 0;

    final runtime = (jsonBody['runtime'] as int?) ?? 0;

    final genres = (jsonBody['genres'] as List<dynamic>?)
            ?.map((g) => (g as Map<String, dynamic>)['name'] as String)
            .toList() ??
        [];

    final cast = <Actor>[];
    final credits = jsonBody['credits'] as Map<String, dynamic>?;
    if (credits != null) {
      final castJson = credits['cast'] as List<dynamic>?;
      if (castJson != null) {
        for (final c in castJson.take(6)) {
          final m = c as Map<String, dynamic>;
          cast.add(Actor(
            id: (m['id']).toString(),
            name: m['name'] as String? ?? '',
            photoUrl: _image(m['profile_path'] as String?),
          ));
        }
      }
    }

    String director = '';
    if (credits != null) {
      final crew = credits['crew'] as List<dynamic>?;
      if (crew != null) {
        final dir = crew.firstWhere(
            (c) => (c as Map<String, dynamic>)['job'] == 'Director',
            orElse: () => null);
        if (dir != null) director = (dir as Map<String, dynamic>)['name'] as String? ?? '';
      }
    }

    final producers = (jsonBody['production_companies'] as List<dynamic>?)
            ?.map((p) => (p as Map<String, dynamic>)['name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .toList() ??
        [];

    return Movie(
      id: (jsonBody['id']).toString(),
      title: jsonBody['title'] as String? ?? '',
      plot: jsonBody['overview'] as String? ?? '',
      posterUrl: poster,
      backdropUrl: backdrop,
      rating: (jsonBody['vote_average'] as num?)?.toDouble() ?? 0.0,
      year: year,
      durationMinutes: runtime,
      genres: genres,
      actors: cast,
      producers: producers,
      director: director,
    );
  }

  @override
  Future<List<Actor>> fetchActors() async {
    final uri = _buildUri('/3/person/popular', {'page': '1'});
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('TMDB fetch failed');
    final body = json.decode(res.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;
    return results.map((p) {
      final person = p as Map<String, dynamic>;
      return Actor(
        id: (person['id']).toString(),
        name: person['name'] as String? ?? '',
        photoUrl: _image(person['profile_path'] as String?),
      );
    }).toList();
  }

  @override
  Future<Actor?> fetchActorById(String id) async {
    final uri = _buildUri('/3/person/$id');
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final person = json.decode(res.body) as Map<String, dynamic>;
    return Actor(
      id: (person['id']).toString(),
      name: person['name'] as String? ?? '',
      photoUrl: _image(person['profile_path'] as String?),
    );
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final uri = _buildUri('/3/search/movie', {'query': query, 'page': '1', 'include_adult': 'false'});
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('TMDB search failed');
    final body = json.decode(res.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;
    return results.map((r) => _movieFromSummary(r as Map<String, dynamic>)).toList();
  }
}
