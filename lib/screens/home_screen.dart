// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_details_screen.dart';
import 'list_details_screen.dart';
import 'friends_screen.dart';
import 'my_lists_screen.dart';

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
      backgroundColor: const Color(0xFF0A0C10),
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: 50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE50914).withOpacity(0.08)),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  title: const SizedBox.shrink(),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: const Color(0xFF14161F), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                      child: IconButton(
                        icon: const Icon(Icons.bookmarks_rounded, color: Colors.white, size: 22),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyListsScreen())),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(color: const Color(0xFF14161F), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                      child: IconButton(
                        icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 22),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendsScreen())),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      FutureBuilder<List<Movie>>(
                        future: _trendingFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const SizedBox(height: 320, child: Center(child: CircularProgressIndicator(color: Color(0xFFE50914))));
                          }
                          return _buildFeaturedBanner(context, snapshot.data!.first);
                        },
                      ),
                      const SizedBox(height: 32),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie))),
      child: Container(
        height: 340,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
          image: DecorationImage(image: NetworkImage(movie.posterUrl), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Colors.transparent, Color(0xFF0A0C10)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.3, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(20),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('FEATURED SPOTLIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 12),
              Text(movie.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5, height: 1.1)),
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.2)),
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.black54,
                    builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
                  );

                  List<Movie> movies = await future;
                  if (!context.mounted) return;
                  Navigator.pop(context);

                  Navigator.push(context, MaterialPageRoute(builder: (_) => ListDetailsScreen(listName: categoryKey, movies: movies)));
                },
                child: const Text('See all', style: TextStyle(fontSize: 14, color: Color(0xFFE50914), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No movies available', style: TextStyle(color: Colors.white54)));

              final movies = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie))),
                    child: Container(
                      width: 125,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.network(movie.posterUrl, fit: BoxFit.cover, width: double.infinity, errorBuilder: (c,e,s) => Container(color: const Color(0xFF14161F), child: const Icon(Icons.broken_image, color: Colors.white24))),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
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