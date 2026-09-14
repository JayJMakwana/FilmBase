// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_details_screen.dart';
import 'list_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  late Future<List<Movie>> _trendingFuture;
  late Future<List<Movie>> _popularFuture;
  late Future<List<Movie>> _topRatedFuture;
  late Future<List<Movie>> _nowPlayingFuture;
  late Future<List<Movie>> _upcomingFuture;
  late Future<List<Movie>> _hindiFuture;
  late Future<List<Movie>> _englishFuture;
  late Future<List<Movie>> _koreanFuture;
  late Future<List<Movie>> _frenchFuture;

  @override
  void initState() {
    super.initState();
    _trendingFuture = _apiService.fetchTrendingMovies();
    _popularFuture = _apiService.fetchPopularMovies();
    _topRatedFuture = _apiService.fetchTopRatedMovies();
    _nowPlayingFuture = _apiService.fetchNowPlayingMovies();
    _upcomingFuture = _apiService.fetchUpcomingMovies();
    _hindiFuture = _apiService.searchMoviesByLanguage('Hindi');
    _englishFuture = _apiService.searchMoviesByLanguage('English');
    _koreanFuture = _apiService.searchMoviesByLanguage('Korean');
    _frenchFuture = _apiService.searchMoviesByLanguage('French');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1017),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Movie>>(
              future: _trendingFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
                }
                final featured = snapshot.data!.first;
                return _buildFeaturedBanner(context, featured);
              },
            ),
            const SizedBox(height: 24),

            _buildMovieRow('Trending Now', _trendingFuture, 'Trending Now'),
            _buildMovieRow('Popular on FilmBase', _popularFuture, 'Popular'),
            _buildMovieRow('Top Rated Masterpieces', _topRatedFuture, 'Top Rated'),
            _buildMovieRow('Now Playing in Theaters', _nowPlayingFuture, 'Now Playing'),
            _buildMovieRow('Hindi Blockbusters', _hindiFuture, 'Hindi'),
            _buildMovieRow('Hollywood English Hits', _englishFuture, 'English'),
            _buildMovieRow('Korean Cinema', _koreanFuture, 'Korean'),
            _buildMovieRow('French Cinema', _frenchFuture, 'French'),
            _buildMovieRow('Coming Soon', _upcomingFuture, 'Upcoming'),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie))),
      child: Container(
        height: 320,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: NetworkImage(movie.posterUrl), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Colors.transparent, Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE50914), borderRadius: BorderRadius.circular(4)),
                child: const Text('FEATURED SPOTLIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 8),
              Text(movie.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieRow(String title, Future<List<Movie>> future, String categoryKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              GestureDetector(
                onTap: () async {
                  // Show loading dialog while fetching page 1 for the full grid view
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
                  );

                  List<Movie> movies = await future;
                  if (!context.mounted) return;
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListDetailsScreen(listName: categoryKey, movies: movies),
                    ),
                  );
                },
                child: const Text('See all', style: TextStyle(fontSize: 14, color: Color(0xFFE50914), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No movies available', style: TextStyle(color: Colors.white54)));
              }
              final movies = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie))),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(movie.posterUrl, fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}