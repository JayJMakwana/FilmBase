// lib/models/movie.dart
class Movie {
  final String title;
  final String year;
  final String posterUrl;
  final String description;
  final String rating;
  final String genre;

  Movie({
    required this.title,
    required this.year,
    required this.posterUrl,
    required this.description,
    required this.rating,
    required this.genre,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // TMDB API response format
    final title = json['title'] ?? json['name'] ?? 'Unknown Title';

    // Extract year from release_date (format: YYYY-MM-DD)
    String year = 'N/A';
    if (json['release_date'] != null && json['release_date'].toString().isNotEmpty) {
      year = json['release_date'].toString().split('-')[0];
    } else if (json['first_air_date'] != null && json['first_air_date'].toString().isNotEmpty) {
      year = json['first_air_date'].toString().split('-')[0];
    }

    // Extract description
    final description = json['overview'] ?? 'No description available.';

    // Extract poster URL - TMDB provides poster_path
    String posterUrl = '';
    if (json['poster_path'] != null && json['poster_path'].toString().isNotEmpty) {
      posterUrl = 'https://image.tmdb.org/t/p/w500${json['poster_path']}';
    }

    // Extract rating - TMDB provides vote_average (0-10)
    final rating = json['vote_average']?.toString() ?? 'N/A';

    // Extract genres - TMDB returns genre_ids, we'll need to map them
    // For now, we'll use a default genre
    String genre = 'Unknown';
    if (json['genre_ids'] != null && json['genre_ids'] is List) {
      // Map genre IDs to names (simplified)
      final genreIds = json['genre_ids'] as List;
      if (genreIds.isNotEmpty) {
        genre = _mapGenreId(genreIds[0] as int);
      }
    }

    return Movie(
      title: title,
      year: year,
      posterUrl: posterUrl,
      description: description,
      rating: rating,
      genre: genre,
    );
  }

  // Map TMDB genre IDs to names
  static String _mapGenreId(int genreId) {
    final genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };
    return genreMap[genreId] ?? 'Unknown';
  }
}