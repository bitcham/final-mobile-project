class UserMovieEntry {
  const UserMovieEntry({
    required this.movieId,
    required this.userRating,
    required this.inWatchlist,
    required this.watchedAt,
  });

  final String movieId;
  final double userRating;
  final bool inWatchlist;
  final String watchedAt;

  factory UserMovieEntry.fromJson(Map<String, dynamic> json) {
    return UserMovieEntry(
      movieId: json['movieId'] as String? ?? '',
      userRating: (json['userRating'] as num?)?.toDouble() ?? 0,
      inWatchlist: json['inWatchlist'] as bool? ?? false,
      watchedAt: json['watchedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movieId': movieId,
      'userRating': userRating,
      'inWatchlist': inWatchlist,
      'watchedAt': watchedAt,
    };
  }
}
