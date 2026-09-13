// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = '1f453dd047f2e300189d00a0ffd4fc8b';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Fetch trending movies
  Future<List<Movie>> fetchTrendingMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to load trending movies: ${response.statusCode}');
  }

  // Fetch popular movies
  Future<List<Movie>> fetchPopularMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to load popular movies: ${response.statusCode}');
  }

  // General keyword search
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(query)}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch search results: ${response.statusCode}');
  }

  // Search by Genre ID
  Future<List<Movie>> searchMoviesByGenre(String genreQuery) async {
    final genreId = _getGenreId(genreQuery);
    if (genreId == -1) return searchMovies(genreQuery);

    final response = await http.get(
      Uri.parse('$baseUrl/discover/movie?api_key=$apiKey&with_genres=$genreId&sort_by=popularity.desc'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to load genre movies');
  }

  // Search by Release Year using Discover endpoint
  Future<List<Movie>> searchMoviesByYear(String year) async {
    final response = await http.get(
      Uri.parse('$baseUrl/discover/movie?api_key=$apiKey&primary_release_year=$year&sort_by=popularity.desc'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to load movies for year $year');
  }

  // Map genre names to TMDB IDs
  int _getGenreId(String genreName) {
    final genreMap = {
      'action': 28,
      'adventure': 12,
      'animation': 16,
      'comedy': 35,
      'crime': 80,
      'documentary': 99,
      'drama': 18,
      'family': 10751,
      'fantasy': 14,
      'history': 36,
      'horror': 27,
      'music': 10402,
      'mystery': 9648,
      'romance': 10749,
      'science fiction': 878,
      'sci-fi': 878,
      'thriller': 53,
      'war': 10752,
      'western': 37,
    };
    return genreMap[genreName.toLowerCase()] ?? -1;
  }
}