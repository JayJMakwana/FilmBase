// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/movie.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final PageController _pageController = PageController();
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;
  int _selectedGenreIndex = 0;

  late Future<List<Movie>> _trendingFuture;
  late Future<List<Movie>> _popularFuture;
  late Future<List<Movie>> _actionFuture;
  late Future<List<Movie>> _sciFiFuture;

  final List<String> genres = const [
    'All', 'Action', 'Comedy', 'Drama', 'Sci-Fi', 'Horror', 'Thriller', 'Romance',
  ];

  @override
  void initState() {
    super.initState();
    // TMDB endpoints with proper genre and trending support
    _trendingFuture = _apiService.fetchTrendingMovies();
    _popularFuture = _apiService.fetchPopularMovies();
    _actionFuture = _apiService.searchMoviesByGenre('action');
    _sciFiFuture = _apiService.searchMoviesByGenre('sci-fi');

    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        if (_currentCarouselIndex < 2) {
          _currentCarouselIndex++;
        } else {
          _currentCarouselIndex = 0;
        }
        _pageController.animateToPage(
          _currentCarouselIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel Section
            SizedBox(
              height: 200,
              child: FutureBuilder<List<Movie>>(
                future: _trendingFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
                  }
                  final featuredMovies = snapshot.data!.take(3).toList();

                  return PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentCarouselIndex = index),
                    itemCount: featuredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = featuredMovies[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MovieDetailsScreen(movie: movie)),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                movie.posterUrl.isNotEmpty
                                    ? Image.network(movie.posterUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A1C24)))
                                    : Container(color: const Color(0xFF1A1C24)),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 16, left: 16, right: 16,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFE50914), borderRadius: BorderRadius.circular(6)),
                                        child: const Text('FEATURED SPOTLIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.white)),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(movie.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Interactive Genre Selector
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedGenreIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGenreIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE50914) : const Color(0xFF1A1C24),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? const Color(0xFFE50914) : Colors.white12),
                      ),
                      child: Text(
                        genres[index],
                        style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Horizontal Movie Rows
            _buildAsyncMovieRow('Trending Now', _trendingFuture),
            _buildAsyncMovieRow('Popular Movies', _popularFuture),
            _buildAsyncMovieRow('Action Hits', _actionFuture),
            _buildAsyncMovieRow('Sci-Fi Adventures', _sciFiFuture),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAsyncMovieRow(String title, Future<List<Movie>> futureMovies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              TextButton(onPressed: () {}, child: const Text('See all', style: TextStyle(color: Color(0xFFE50914), fontSize: 13))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: FutureBuilder<List<Movie>>(
            future: futureMovies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No movies found', style: TextStyle(color: Colors.white38)));
              }

              final movies = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MovieDetailsScreen(movie: movie)),
                      );
                    },
                    child: Container(
                      width: 135,
                      margin: const EdgeInsets.only(right: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                movie.posterUrl.isNotEmpty
                                    ? Image.network(
                                  movie.posterUrl,
                                  height: 175,
                                  width: 135,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 175,
                                    width: 135,
                                    color: const Color(0xFF1A1C24),
                                    child: const Icon(Icons.broken_image, color: Colors.white38),
                                  ),
                                )
                                    : Container(
                                  height: 175,
                                  width: 135,
                                  color: const Color(0xFF1A1C24),
                                  child: const Icon(Icons.movie, color: Colors.white38),
                                ),
                                Positioned(
                                  top: 8, right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.75), borderRadius: BorderRadius.circular(6)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                                        const SizedBox(width: 2),
                                        Text(movie.rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          Text(movie.genre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}