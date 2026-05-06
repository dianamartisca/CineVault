import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/genre.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/movies_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/section_header.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  String _selectedGenre = Genre.all.first.id;

  @override
  Widget build(BuildContext context) {
    final moviesProvider = context.watch<MoviesProvider>();
    final favProvider = context.watch<FavoritesProvider>();
    final filtered = moviesProvider.moviesByGenre(_selectedGenre);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Browse by Genre'),
            _genreSelector(),
            const SizedBox(height: 4),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No movies in this genre',
                          style:
                              TextStyle(color: AppTheme.textSecondary)),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final m = filtered[i];
                        return MovieCard(
                          movie: m,
                          isFavorite: favProvider.isMovieFavorite(m.id),
                          onTap: () => context.push('/movie/${m.id}'),
                          onFavoriteTap: () =>
                              favProvider.toggleMovieFavorite(m.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genreSelector() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: Genre.all.length,
        itemBuilder: (_, i) {
          final genre = Genre.all[i];
          final isSelected = genre.id == _selectedGenre;
          return GestureDetector(
            onTap: () => setState(() => _selectedGenre = genre.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                '${genre.emoji} ${genre.name}',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
