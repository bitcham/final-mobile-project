const movieJson = '''
{
  "movies": [
    {
      "id": "neon-horizon",
      "title": "Neon Horizon",
      "synopsis": "In a world where memories are currency...",
      "releaseYear": 2024,
      "runtimeMinutes": 165,
      "rating": 8.9,
      "ageRating": "PG-13",
      "posterAsset": "assets/images/neon_horizon_poster.jpg",
      "backdropAsset": "assets/images/neon_horizon_backdrop.jpg",
      "trailerUrl": "https://example.com/neon-horizon",
      "category": "nowPlaying",
      "genres": ["Sci-Fi", "Thriller"],
      "cast": [],
      "reviews": [],
      "mediaItems": []
    },
    {
      "id": "the-long-walk",
      "title": "The Long Walk",
      "synopsis": "A character drama on a lonely road.",
      "releaseYear": 2025,
      "runtimeMinutes": 134,
      "rating": 8.4,
      "ageRating": "PG-13",
      "posterAsset": "assets/images/the_long_walk_poster.jpg",
      "backdropAsset": "assets/images/the_long_walk_backdrop.jpg",
      "trailerUrl": "https://example.com/the-long-walk",
      "category": "nowPlaying",
      "genres": ["Drama"],
      "cast": [],
      "reviews": [],
      "mediaItems": []
    },
    {
      "id": "quantum-leap",
      "title": "Quantum Leap",
      "synopsis": "A sci-fi journey through collapsing timelines.",
      "releaseYear": 2026,
      "runtimeMinutes": 150,
      "rating": 9.1,
      "ageRating": "PG-13",
      "posterAsset": "assets/images/quantum_leap_poster.jpg",
      "backdropAsset": "assets/images/quantum_leap_backdrop.jpg",
      "trailerUrl": "https://example.com/quantum-leap",
      "category": "topRated",
      "genres": ["Sci-Fi", "Adventure"],
      "cast": [],
      "reviews": [],
      "mediaItems": []
    }
  ],
  "userMovieEntries": [
    {
      "movieId": "neon-horizon",
      "userRating": 5.0,
      "inWatchlist": true,
      "watchedAt": "2026-04-28"
    },
    {
      "movieId": "quantum-leap",
      "userRating": 0.0,
      "inWatchlist": true,
      "watchedAt": ""
    }
  ]
}
''';
