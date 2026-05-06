class Genre {
  final String id;
  final String name;
  final String emoji;

  const Genre({
    required this.id,
    required this.name,
    required this.emoji,
  });

  static const List<Genre> all = [
    Genre(id: 'Action', name: 'Action', emoji: '💥'),
    Genre(id: 'Comedy', name: 'Comedy', emoji: '😂'),
    Genre(id: 'Drama', name: 'Drama', emoji: '🎭'),
    Genre(id: 'Horror', name: 'Horror', emoji: '👻'),
    Genre(id: 'Romance', name: 'Romance', emoji: '❤️'),
    Genre(id: 'Thriller', name: 'Thriller', emoji: '🔪'),
    Genre(id: 'Animation', name: 'Animation', emoji: '🎨'),
    Genre(id: 'Documentary', name: 'Documentary', emoji: '🎥'),
    Genre(id: 'Fantasy', name: 'Fantasy', emoji: '🧙'),
  ];
}
