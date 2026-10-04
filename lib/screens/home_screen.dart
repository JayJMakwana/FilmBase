// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../theme/filmbase_theme.dart';
import '../widgets/cinematic_chrome.dart';
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
      backgroundColor: FilmbaseColors.canvas,
      body: Stack(
        children: [
          const GlowBackdrop(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  title: const Row(
                    children: [
                      Text('Film', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: FilmbaseColors.accent, letterSpacing: -0.8)),
                      Text('Base', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: FilmbaseColors.text, letterSpacing: -0.8)),
                    ],
                  ),
                  actions: [
                    GlassIconButton(
                      icon: Icons.bookmarks_rounded,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyListsScreen())),
                    ),
                    const SizedBox(width: 8),
                    GlassIconButton(
                      icon: Icons.person_add_rounded,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FriendsScreen())),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      FutureBuilder<List<Movie>>(
                        future: _trendingFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const SizedBox(height: 340, child: Center(child: CircularProgressIndicator(color: FilmbaseColors.accent)));
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
        height: 360,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: FilmbaseColors.hairline),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 28, offset: const Offset(0, 14)),
            BoxShadow(color: FilmbaseColors.accent.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
          ],
          image: DecorationImage(image: NetworkImage(movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Colors.transparent, Color(0xCC07080C), Color(0xF207080C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.28, 0.72, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(22),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: FilmbaseColors.accent.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('FEATURED SPOTLIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.1)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: FilmbaseColors.gold.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: FilmbaseColors.gold, size: 14),
                        const SizedBox(width: 4),
                        Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: FilmbaseColors.gold, fontWeight: FontWeight.w700, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(movie.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: FilmbaseColors.text, letterSpacing: -0.6, height: 1.1)),
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: FilmbaseColors.text, letterSpacing: -0.2)),
              ),
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.black54,
                    builder: (_) => const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent)),
                  );

                  List<Movie> movies = await future;
                  if (!context.mounted) return;
                  Navigator.pop(context);

                  Navigator.push(context, MaterialPageRoute(builder: (_) => ListDetailsScreen(listName: categoryKey, movies: movies)));
                },
                child: const Text('See all', style: TextStyle(fontSize: 13, color: FilmbaseColors.accent, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent));
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No movies available', style: TextStyle(color: FilmbaseColors.muted)));

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
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.42), blurRadius: 16, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              movie.posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(color: FilmbaseColors.surface, child: const Icon(Icons.broken_image, color: Colors.white24)),
                            ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Color(0xCC07080C)],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: Text(
                                movie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: FilmbaseColors.text, height: 1.2),
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
        const SizedBox(height: 18),
      ],
    );
  }
}
