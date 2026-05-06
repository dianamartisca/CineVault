import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/movies_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/actor_card.dart';
import '../../widgets/section_header.dart';

class MovieDetailScreen extends StatelessWidget {
  final String movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = context.watch<MoviesProvider>();
    final favProvider = context.watch<FavoritesProvider>();

    final movie = moviesProvider.movies.firstWhere(
      (m) => m.id == movieId,
      orElse: () => throw Exception('Movie not found'),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, movie, favProvider),
          SliverToBoxAdapter(
            child: _buildBody(context, movie, favProvider, moviesProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, Movie movie, FavoritesProvider fav) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.background,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Colors.black54, shape: BoxShape.circle),
          child:
              const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => fav.toggleMovieFavorite(movie.id),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
                color: Colors.black54, shape: BoxShape.circle),
            child: Icon(
              fav.isMovieFavorite(movie.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: fav.isMovieFavorite(movie.id)
                  ? AppTheme.primary
                  : Colors.white,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movie.backdropUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: AppTheme.cardColor,
                child: const Icon(Icons.movie,
                    color: AppTheme.textSecondary, size: 60),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.background],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Movie movie, FavoritesProvider fav,
      MoviesProvider moviesProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  movie.title,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppTheme.gold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Text('/10',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _metaChip(Icons.calendar_today, movie.year.toString()),
              const SizedBox(width: 10),
              _metaChip(Icons.access_time, movie.formattedDuration),
            ],
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: movie.genres
                .map((g) => _genreTag(g))
                .toList(),
          ),
          const SizedBox(height: 20),

          const Text('Plot',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(movie.plot,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.6)),
          const SizedBox(height: 20),

          _infoRow('Director', movie.director),
          const SizedBox(height: 8),

          _infoRow('Producers', movie.producers.join(', ')),
          const SizedBox(height: 24),

          Divider(color: Colors.white.withOpacity(0.08)),

          const SectionHeader(title: 'Cast'),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movie.actors.length,
              itemBuilder: (_, i) {
                final actor = movie.actors[i];
                return ActorCard(
                  actor: actor,
                  isFavorite: fav.isActorFavorite(actor.id),
                  onTap: () => _showActorMovies(context, actor, moviesProvider),
                  onFavoriteTap: () => fav.toggleActorFavorite(actor.id),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 14),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _genreTag(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        genre.toUpperCase(),
        style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showActorMovies(BuildContext context, actor, MoviesProvider moviesProvider) {
    final movies = moviesProvider.moviesForActor(actor.id);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Movies with ${actor.name}', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            Divider(),
            if (movies.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('No movies found for this actor.'),
              )
            else
              ...movies.map((m) => ListTile(
                    title: Text(m.title),
                    subtitle: Text('${m.year}  •  ${m.formattedDuration}'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/movie/${m.id}');
                    },
                  ))
          ],
        ),
      ),
    );
  }
}
