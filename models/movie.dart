import 'actor.dart';

class Movie {
  final String id;
  final String title;
  final String plot;
  final String posterUrl;
  final String backdropUrl;
  final double rating;
  final int year;
  final int durationMinutes;
  final List<String> genres;
  final List<Actor> actors;
  final List<String> producers;
  final String director;

  const Movie({
    required this.id,
    required this.title,
    required this.plot,
    required this.posterUrl,
    required this.backdropUrl,
    required this.rating,
    required this.year,
    required this.durationMinutes,
    required this.genres,
    required this.actors,
    required this.producers,
    required this.director,
  });

  String get formattedDuration {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      plot: json['plot'] as String,
      posterUrl: json['posterUrl'] as String,
      backdropUrl: json['backdropUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      year: json['year'] as int,
      durationMinutes: json['durationMinutes'] as int,
      genres: List<String>.from(json['genres'] as List),
      actors: (json['actors'] as List)
          .map((a) => Actor.fromJson(a as Map<String, dynamic>))
          .toList(),
      producers: List<String>.from(json['producers'] as List),
      director: json['director'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'plot': plot,
        'posterUrl': posterUrl,
        'backdropUrl': backdropUrl,
        'rating': rating,
        'year': year,
        'durationMinutes': durationMinutes,
        'genres': genres,
        'actors': actors.map((a) => a.toJson()).toList(),
        'producers': producers,
        'director': director,
      };
}
