import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home/home_screen.dart';
import 'screens/movie_detail/movie_detail_screen.dart';
import 'screens/genre/genre_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/actors/actors_screen.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_filter_outlined),
            selectedIcon: Icon(Icons.movie_filter),
            label: 'Genres',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Actors',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          )
        ],
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'movies',
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
        ]),

        StatefulShellBranch(routes: [
          GoRoute(
            path: '/genres',
            builder: (_, __) => const GenreScreen(),
          ),
        ]),

        StatefulShellBranch(routes: [
          GoRoute(
            path: '/actors',
            builder: (_, __) => const ActorsScreen(),
          ),
        ]),

        StatefulShellBranch(routes: [
          GoRoute(
            path: '/favorites',
            builder: (_, __) => const FavoritesScreen(),
          ),
        ]),
      ],
    ),

    GoRoute(
      path: '/movie/:id',
      builder: (_, state) =>
          MovieDetailScreen(movieId: state.pathParameters['id']!),
    ),
  ],
);
