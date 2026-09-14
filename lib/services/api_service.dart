// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = '1f453dd047f2e300189d00a0ffd4fc8b';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  Future<List<Movie>> fetchTrendingMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to load trending movies');
  }

  Future<List<Movie>> fetchPopularMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to load popular movies');
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await http.get(Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(query)}'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to search movies');
  }

  // 1. Genres with page support
  Future<List<Movie>> searchMoviesByGenre(String genreQuery, {int page = 1}) async {
    final genreId = _getGenreId(genreQuery);
    if (genreId == -1) return searchMovies(genreQuery);

    final response = await http.get(Uri.parse('$baseUrl/discover/movie?api_key=$apiKey&with_genres=$genreId&sort_by=popularity.desc&page=$page'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to load genre movies');
  }

  // 2. Release Year with page support
  Future<List<Movie>> searchMoviesByYear(String year, {int page = 1}) async {
    final response = await http.get(Uri.parse('$baseUrl/discover/movie?api_key=$apiKey&primary_release_year=$year&sort_by=popularity.desc&page=$page'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to load year movies');
  }

  // 3. Languages with page support
  Future<List<Movie>> searchMoviesByLanguage(String langName, {int page = 1}) async {
    final langCode = _getLanguageCode(langName);
    final response = await http.get(Uri.parse('$baseUrl/discover/movie?api_key=$apiKey&with_original_language=$langCode&sort_by=popularity.desc&page=$page'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to load language movies');
  }

  // 4. Curated Collections (Award Winners, Top Box Office, etc.) with page support
  Future<List<Movie>> fetchCuratedCollection(String collectionName, {int page = 1}) async {
    String endpoint = '$baseUrl/discover/movie?api_key=$apiKey&sort_by=popularity.desc&page=$page';

    if (collectionName == 'Award Winners' || collectionName == 'Critically Acclaimed') {
      endpoint = '$baseUrl/discover/movie?api_key=$apiKey&vote_average.gte=8.0&vote_count.gte=1000&sort_by=vote_average.desc&page=$page';
    } else if (collectionName == 'Top Box Office') {
      endpoint = '$baseUrl/discover/movie?api_key=$apiKey&sort_by=revenue.desc&page=$page';
    } else if (collectionName == 'Indie Darlings') {
      endpoint = '$baseUrl/discover/movie?api_key=$apiKey&with_genres=18&vote_average.gte=7.5&sort_by=vote_count.asc&page=$page';
    }

    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    }
    throw Exception('Failed to load collection');
  }

  int _getGenreId(String name) {
    final map = {'action': 28, 'adventure': 12, 'animation': 16, 'comedy': 35, 'crime': 80, 'documentary': 99, 'drama': 18, 'family': 10751, 'fantasy': 14, 'history': 36, 'horror': 27, 'music': 10402, 'mystery': 9648, 'romance': 10749, 'science fiction': 878, 'sci-fi': 878, 'thriller': 53, 'war': 10752, 'western': 37};
    return map[name.toLowerCase()] ?? -1;
  }

  String _getLanguageCode(String name) {
    final map = {'english': 'en', 'spanish': 'es', 'hindi': 'hi', 'korean': 'ko', 'japanese': 'ja', 'french': 'fr', 'german': 'de'};
    return map[name.toLowerCase()] ?? 'en';
  }
}