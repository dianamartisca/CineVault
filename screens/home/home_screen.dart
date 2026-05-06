import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/movies_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/actor_card.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moviesProvider = context.watch<MoviesProvider>();
    final favProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      body: SafeArea(
        child: moviesProvider.state == LoadState.loading
            ? const Center(child: CircularProgressIndicator())
            : moviesProvider.state == LoadState.error
                ? _errorView(moviesProvider)
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _header(context)),
                      SliverToBoxAdapter(child: _searchBar(moviesProvider)),
                      if (moviesProvider.searchQuery.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _searchResults(moviesProvider, favProvider),
                        )
                      else ...[
                        SliverToBoxAdapter(child: _featuredBanner(moviesProvider, favProvider)),
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: '🔥 Trending Now',
                            actionLabel: 'See all',
                            onAction: () => context.go('/genres'),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _horizontalMovieList(
                              moviesProvider, favProvider),
                        ),
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: '🎭 Popular Actors',
                            actionLabel: 'See all',
                            onAction: () => context.go('/actors'),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _horizontalActorList(
                              moviesProvider, favProvider),
                        ),
                        const SliverToBoxAdapter(
                            child: SizedBox(height: 30)),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CineVault',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.primary,
                    fontSize: 28,
                  )),
          const Text('What will you watch today?',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _searchBar(MoviesProvider moviesProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        controller: _searchController,
        onChanged: moviesProvider.setSearchQuery,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search movies, actors, directors...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _featuredBanner(MoviesProvider p, FavoritesProvider fav) {
    if (p.movies.isEmpty) return const SizedBox.shrink();
    final movie = p.movies.first;
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(
            image: NetworkImage(movie.backdropUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('FEATURED',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2)),
              ),
              const SizedBox(height: 6),
              Text(movie.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              Row(
                children: [
                  const Icon(Icons.star, color: AppTheme.gold, size: 14),
                  const SizedBox(width: 4),
                  Text(movie.rating.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  Text(movie.formattedDuration,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _horizontalMovieList(MoviesProvider p, FavoritesProvider fav) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: p.movies.length,
        itemBuilder: (_, i) {
          final m = p.movies[i];
          return MovieCard(
            movie: m,
            isFavorite: fav.isMovieFavorite(m.id),
            onTap: () => context.push('/movie/${m.id}'),
            onFavoriteTap: () => fav.toggleMovieFavorite(m.id),
          );
        },
      ),
    );
  }

  Widget _horizontalActorList(MoviesProvider p, FavoritesProvider fav) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: p.actors.length,
            itemBuilder: (_, i) {
          final a = p.actors[i];
          return ActorCard(
            actor: a,
            isFavorite: fav.isActorFavorite(a.id),
            onTap: () => _showActorMovies(context, a, p),
            onFavoriteTap: () => fav.toggleActorFavorite(a.id),
          );
        },
      ),
    );
  }

  Widget _searchResults(MoviesProvider p, FavoritesProvider fav) {
    final q = p.searchQuery.toLowerCase();
    final movieMatches = p.movies;
    final actorMatches = p.actors.where((a) => a.name.toLowerCase().contains(q)).toList();
    final total = movieMatches.length + actorMatches.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$total result(s) for "${p.searchQuery}"',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          if (actorMatches.isNotEmpty) ...[
            const Text('Actors', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            ...actorMatches.map((a) => ActorListTile(
                  actor: a,
                  isFavorite: fav.isActorFavorite(a.id),
                  onTap: () => _showActorMovies(context, a, p),
                  onFavoriteTap: () => fav.toggleActorFavorite(a.id),
                )),
            const SizedBox(height: 12),
          ],
          ...movieMatches.map((m) => MovieListTile(
                movie: m,
                isFavorite: fav.isMovieFavorite(m.id),
                onTap: () => context.push('/movie/${m.id}'),
                onFavoriteTap: () => fav.toggleMovieFavorite(m.id),
              )),
        ],
      ),
    );
  }

  Widget _errorView(MoviesProvider p) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.primary, size: 48),
          const SizedBox(height: 12),
          Text(p.errorMessage,
              style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: p.loadAll,
            child: const Text('Retry'),
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
