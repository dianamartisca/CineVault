import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/movies_provider.dart';
import '../../widgets/actor_card.dart';
import '../../widgets/section_header.dart';

class ActorsScreen extends StatelessWidget {
  const ActorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = context.watch<MoviesProvider>();
    final favProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'All Actors'),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 16,
                ),
                itemCount: moviesProvider.actors.length,
                itemBuilder: (_, i) {
                  final a = moviesProvider.actors[i];
                  return ActorCard(
                    actor: a,
                    isFavorite: favProvider.isActorFavorite(a.id),
                    onTap: () => _showActorMovies(context, a, moviesProvider),
                    onFavoriteTap: () =>
                        favProvider.toggleActorFavorite(a.id),
                  );
                },
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
}
