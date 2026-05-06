import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/movies_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/actor_card.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/section_header.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moviesProvider = context.watch<MoviesProvider>();
    final favProvider = context.watch<FavoritesProvider>();

    final favMovies =
        moviesProvider.favoriteMovies(favProvider.favoriteMovieIds);
    final favActors =
        moviesProvider.favoriteActors(favProvider.favoriteActorIds);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SectionHeader(title: 'My Favorites'),
            TabBar(
              controller: _tab,
              indicatorColor: AppTheme.primary,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              tabs: [
                Tab(text: 'Movies (${favMovies.length})'),
                Tab(text: 'Actors (${favActors.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  favMovies.isEmpty
                      ? _emptyState('No favorite movies yet',
                          'Tap ❤️ on any movie to save it here')
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          itemCount: favMovies.length,
                          itemBuilder: (_, i) {
                            final m = favMovies[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: MovieListTile(
                                movie: m,
                                isFavorite: true,
                                onTap: () =>
                                    context.push('/movie/${m.id}'),
                                onFavoriteTap: () =>
                                    favProvider.toggleMovieFavorite(m.id),
                              ),
                            );
                          },
                        ),
                  favActors.isEmpty
                      ? _emptyState('No favorite actors yet',
                          'Tap ❤️ on any actor to save them here')
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          itemCount: favActors.length,
                          itemBuilder: (_, i) {
                            final a = favActors[i];
                            return ActorListTile(
                              actor: a,
                              isFavorite: true,
                              onTap: () => _showActorMovies(context, a, moviesProvider),
                              onFavoriteTap: () =>
                                  favProvider.toggleActorFavorite(a.id),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border,
              color: AppTheme.textSecondary, size: 64),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
