class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String? backdropPath; // Add this
  final String releaseDate;
  final double voteAverage;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      overview: json['overview'] ?? 'No overview available.',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'], // Parse backdrop
      releaseDate: json['release_date'] ?? '2026',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
    );
  }

  String get posterUrl => posterPath.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  // Add a getter for the landscape backdrop
  String get backdropUrl => backdropPath != null && backdropPath!.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : posterUrl; // Fallback to poster if backdrop is missing
}