// lib/models/movie.dart
class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String? backdropPath;
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
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '2026',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
    );
  }

  // Proxy base for images to bypass college network blocks
  static const String _proxyImageBase = 'https://filmbase-proxy.jaym15993.workers.dev/t/p';

  String get posterUrl => posterPath.isNotEmpty
      ? '$_proxyImageBase/w500$posterPath'
      : '';

  // Getter for the landscape backdrop routed through proxy
  String get backdropUrl => backdropPath != null && backdropPath!.isNotEmpty
      ? '$_proxyImageBase/w780$backdropPath'
      : posterUrl; // Fallback to poster if backdrop is missing
}