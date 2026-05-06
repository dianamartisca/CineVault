# 🎬 CineVault — Flutter Movie App

A dark-themed Android movie browsing app built with Flutter.

---

## Features
- Browse movies with poster, rating, year, and genre tags
- Full detail screen: plot, cast, director, producers
- Browse movies grouped by genre (animated filter chips)
- Actor detail screen with filmography
- Favorite movies & actors (persisted via SharedPreferences)
- Live search across title, director, and actors
- Featured movie banner on the home screen

---

## Project Structure

```
MovieApp/
├── main.dart                  # Entry point — providers & theme wiring
├── router.dart                # go_router config + NavigationBar shell
│
├── models/
│   ├── movie.dart             # Movie data model
│   ├── actor.dart             # Actor data model
│   └── genre.dart             # Genre enum + metadata
│
├── providers/
│   ├── movies_provider.dart   # State management for movies & actors
│   └── favorites_provider.dart # Persisted favorites (movies & actors)
│
├── services/
│   ├── movie_repository.dart       # Abstract repository interface
│   └── tmdb_movie_repository.dart  # TMDB API implementation
│
├── theme/
│   └── app_theme.dart         # Dark theme, colors, fonts (Google Fonts)
│
├── widgets/
│   ├── movie_card.dart        # MovieCard (thumbnail) + MovieListTile (row)
│   ├── actor_card.dart        # ActorCard (circle) + ActorListTile (row)
│   └── section_header.dart    # Reusable section header with optional CTA
│
└── screens/
    ├── home/
    │   └── home_screen.dart         # Home feed + search
    ├── movie_detail/
    │   └── movie_detail_screen.dart # Full movie detail
    ├── genre/
    │   └── genre_screen.dart        # Genre filter + grid
    ├── favorites/
    │   └── favorites_screen.dart    # Tabbed favorites (movies / actors)
    └── actors/
        ├── actors_screen.dart       # All actors grid
        └── actor_detail_screen.dart # Actor filmography
```

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0
- Android Studio or VS Code with Flutter extension

### Run

```bash
flutter pub get
flutter run -t main.dart
```

### Build APK

```bash
flutter build apk --release
```

---

## API Integration

This app uses [TMDB (The Movie Database)](https://www.themoviedb.org/) for real movie and actor data.

### Setup

1. Get your free API key from [TMDB](https://www.themoviedb.org/settings/api).
2. Create a `.env` file in the project root:

```
TMDB_API_KEY=your_key_here
```

3. Run the app:

```bash
flutter pub get
flutter run
```

The app automatically loads the API key from `.env` on startup.
```