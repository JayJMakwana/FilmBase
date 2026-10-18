// lib/screens/home_screen.dart
import 'dart:ui';
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

  Future<void> _openCategoryList(String title, Future<List<Movie>> future) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: FilmbaseColors.accent),
      ),
    );

    final List<Movie> movies = await future;
    if (!mounted) return;
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListDetailsScreen(listName: title, movies: movies),
      ),
    );
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
                      Text(
                        'Film',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: FilmbaseColors.accent,
                          letterSpacing: -0.8,
                        ),
                      ),
                      Text(
                        'Base',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: FilmbaseColors.text,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    GlassIconButton(
                      icon: Icons.bookmarks_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyListsScreen()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassIconButton(
                      icon: Icons.person_add_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FriendsScreen()),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildCinematicHeroBanner(context),
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

  // --- STATIC CINEMATIC HERO BANNER (Ported from ASP.NET Razor View) ---
  Widget _buildCinematicHeroBanner(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;
    final bool isTablet = screenWidth > 550;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: isDesktop ? 420 : (isTablet ? 380 : 340),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // 1. Background Image (Loads local asset first, falls back to TMDB proxy URL)
            Positioned.fill(
              child: Image.asset(
                'assets/images/cinematic_hero_banner.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://filmbase-proxy.jaym15993.workers.dev/t/p/original/b33nnKl1GSFbao4l3fZDDqsTc0F.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF07090E)),
                  );
                },
              ),
            ),

            // 2. Bottom-to-Top Gradient: linear-gradient(to top, #07090e 5%, rgba(7,9,14,0.7) 40%, rgba(7,9,14,0.3) 100%)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFF07090E),
                      Color(0xB307090E),
                      Color(0x4D07090E),
                    ],
                    stops: [0.05, 0.40, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Left-to-Right Gradient: linear-gradient(to right, #07090e 20%, rgba(7,9,14,0.8) 50%, rgba(7,9,14,0.2) 100%)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF07090E),
                      Color(0xCC07090E),
                      Color(0x3307090E),
                    ],
                    stops: [0.20, 0.50, 1.0],
                  ),
                ),
              ),
            ),

            // 4. Foreground Content (max-w-2xl equivalent)
            Padding(
              padding: EdgeInsets.all(isDesktop ? 44.0 : (isTablet ? 32.0 : 24.0)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Frosted Pill Badge
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: FilmbaseColors.accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: FilmbaseColors.accent.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🎬', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 6),
                              Text(
                                'Cinema Catalog & Personal Watchlists',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main Heading
                    Text(
                      'Welcome to FilmBase',
                      style: TextStyle(
                        fontSize: isDesktop ? 44 : (isTablet ? 34 : 28),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle Description
                    Text(
                      'Track, discover, and save your favorite movies in one place. Browse curated collections, search international cinema, and curate your personalized watchlist.',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: const Color(0xFFCBD5E1), // slate-300
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        // Primary Button: Discover Titles
                        GestureDetector(
                          onTap: () => _openCategoryList('Popular', _popularFuture),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: FilmbaseColors.accent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: FilmbaseColors.accent.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🧭', style: TextStyle(fontSize: 14)),
                                SizedBox(width: 8),
                                Text(
                                  'Discover Popular',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Secondary Button: Trending This Week
                        GestureDetector(
                          onTap: () => _openCategoryList('Trending This Week', _trendingFuture),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🔥', style: TextStyle(fontSize: 14)),
                                SizedBox(width: 8),
                                Text(
                                  'Trending This Week',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: FilmbaseColors.text,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _openCategoryList(categoryKey, future),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    color: FilmbaseColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No movies available', style: TextStyle(color: FilmbaseColors.muted)),
                );
              }

              final movies = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
                    ),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.42),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
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
                              errorBuilder: (c, e, s) => Container(
                                color: FilmbaseColors.surface,
                                child: const Icon(Icons.broken_image, color: Colors.white24),
                              ),
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: FilmbaseColors.text,
                                  height: 1.2,
                                ),
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