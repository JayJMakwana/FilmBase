// lib/screens/search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../theme/filmbase_theme.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  Future<List<Movie>>? _searchResults;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Forces the UI to rebuild instantly on every single keystroke
    // This guarantees the 'X' clear button appears and the app registers the text.
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Bypasses the timer and searches immediately
  void _triggerSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = null);
    } else {
      setState(() {
        _searchResults = _apiService.searchMovies(query.trim());
      });
    }
  }

  // Triggered every time a key is pressed (with a delay to prevent API spam)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      _triggerSearch('');
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _triggerSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FilmbaseColors.canvas,
      appBar: AppBar(
        backgroundColor: FilmbaseColors.canvas,
        elevation: 0,
        iconTheme: const IconThemeData(color: FilmbaseColors.text),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: FilmbaseColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FilmbaseColors.hairline),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: FilmbaseColors.text, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search movies...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: _triggerSearch, // Fires instantly if you press Enter
          ),
        ),
        actions: [
          // This will now instantly appear the moment you type
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_rounded, color: Colors.white.withValues(alpha: 0.5)),
              onPressed: () {
                _searchController.clear();
                _triggerSearch('');
              },
            )
        ],
      ),
      body: _searchResults == null
          ? Center(child: Text('Type a movie name to start searching!', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 16)))
          : FutureBuilder<List<Movie>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No results found.', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))));
          }

          final movies = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: FilmbaseColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: FilmbaseColors.hairline),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: movie.posterUrl.isNotEmpty
                        ? Image.network(
                      movie.posterUrl,
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_rounded, size: 50, color: Colors.white24),
                    )
                        : const Icon(Icons.movie_rounded, size: 50, color: Colors.white24),
                  ),
                  title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold, color: FilmbaseColors.text)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text('${movie.releaseDate}  •  ⭐ ${movie.voteAverage.toStringAsFixed(1)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailsScreen(movie: movie)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
