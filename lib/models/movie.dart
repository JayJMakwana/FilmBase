// lib/models/movie.dart
class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final String mediaType; // 'movie' or 'tv'

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    this.mediaType = 'movie',
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Detect if the payload is a TV show/Anime or a Movie
    final bool isTv = json['media_type'] == 'tv' ||
        (json['title'] == null && json['name'] != null) ||
        json.containsKey('first_air_date');

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'No Title',
      overview: (json['overview'] != null && json['overview'].toString().isNotEmpty)
          ? json['overview']
          : 'No overview available.',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '2026',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      mediaType: isTv ? 'tv' : 'movie',
    );
  }

  // Proxy base for images to bypass college network blocks
  static const String _proxyImageBase = 'https://filmbase-proxy.jaym15993.workers.dev/t/p';

  String get posterUrl {
    if (posterPath.isEmpty) return '';
    if (posterPath.startsWith('http')) return posterPath;
    return '$_proxyImageBase/w500$posterPath';
  }

  // Getter for the landscape backdrop routed through proxy
  String get backdropUrl => backdropPath != null && backdropPath!.isNotEmpty
      ? '$_proxyImageBase/w780$backdropPath'
      : posterUrl;
}