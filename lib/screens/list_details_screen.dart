// lib/screens/list_details_screen.dart
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_details_screen.dart';

enum SortOption { defaultSort, az, za, newest, oldest }

class ListDetailsScreen extends StatefulWidget {
  final String listName;
  final List<Movie> movies;

  const ListDetailsScreen({
    super.key,
    required this.listName,
    required this.movies,
  });

  @override
  State<ListDetailsScreen> createState() => _ListDetailsScreenState();
}

class _ListDetailsScreenState extends State<ListDetailsScreen> {
  late ScrollController _scrollController;
  late List<Movie> _movies;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  final ApiService _apiService = ApiService();
  SortOption _currentSort = SortOption.defaultSort;

  @override
  void initState() {
    super.initState();
    _movies = List.from(widget.movies);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() async {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMoreData) {
      setState(() => _isLoadingMore = true);
      _currentPage++;

      try {
        List<Movie> moreMovies = await _fetchMoreMovies(_currentPage);
        setState(() {
          if (moreMovies.isEmpty) {
            _hasMoreData = false;
          } else {
            _movies.addAll(moreMovies);
          }
          _isLoadingMore = false;
        });
      } catch (e) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<List<Movie>> _fetchMoreMovies(int page) async {
    final text = widget.listName;
    if (_isGenre(text)) return await _apiService.searchMoviesByGenre(text, page: page);
    else if (int.tryParse(text) != null) return await _apiService.searchMoviesByYear(text, page: page);
    else if (['English', 'Spanish', 'Hindi', 'Korean', 'Japanese', 'French', 'German'].contains(text) || text.contains('Hits') || text.contains('Cinema')) {
      String langQuery = text.replaceAll(' Hits', '').replaceAll(' Blockbusters', '').replaceAll(' Cinema', '');
      return await _apiService.searchMoviesByLanguage(langQuery, page: page);
    }
    else if (['Award Winners', 'Top Box Office', 'Critically Acclaimed', 'Indie Darlings', 'Based on a Book'].contains(text)) return await _apiService.fetchCuratedCollection(text, page: page);
    else if (text.contains('Top Rated')) return await _apiService.fetchTopRatedMovies(page: page);
    else if (text.contains('Now Playing')) return await _apiService.fetchNowPlayingMovies(page: page);
    else if (text.contains('Upcoming') || text.contains('Coming Soon')) return await _apiService.fetchUpcomingMovies(page: page);
    else if (text.contains('Trending')) return await _apiService.fetchTrendingMovies(page: page);
    else if (text.contains('Popular')) return await _apiService.fetchPopularMovies(page: page);
    else return await _apiService.searchMovies(text, page: page);
  }

  bool _isGenre(String name) {
    final map = {'action': 28, 'adventure': 12, 'animation': 16, 'comedy': 35, 'crime': 80, 'documentary': 99, 'drama': 18, 'family': 10751, 'fantasy': 14, 'history': 36, 'horror': 27, 'music': 10402, 'mystery': 9648, 'romance': 10749, 'science fiction': 878, 'sci-fi': 878, 'thriller': 53, 'war': 10752, 'western': 37};
    return map.containsKey(name.toLowerCase());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columns = screenWidth > 1400 ? 7 : screenWidth > 1100 ? 6 : screenWidth > 900 ? 5 : screenWidth > 700 ? 4 : screenWidth > 500 ? 3 : 2;
    double childAspectRatio = columns >= 5 ? 0.6 : columns == 4 ? 0.57 : columns == 3 ? 0.58 : 0.55;

    List<Movie> displayMovies = List.from(_movies);
    if (_currentSort != SortOption.defaultSort) {
      displayMovies.sort((a, b) {
        switch (_currentSort) {
          case SortOption.az: return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          case SortOption.za: return b.title.toLowerCase().compareTo(a.title.toLowerCase());
          case SortOption.newest: return b.releaseDate.compareTo(a.releaseDate);
          case SortOption.oldest: return a.releaseDate.compareTo(b.releaseDate);
          default: return 0;
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10), // Crisp dark background
      body: Stack(
        children: [
          // Subtle background gradient glow
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0055FF).withOpacity(0.08)), // Blue glow for API lists
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Modern Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.listName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: PopupMenuButton<SortOption>(
                          icon: const Icon(Icons.sort_rounded, color: Colors.white, size: 20),
                          color: const Color(0xFF14161F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.1))),
                          onSelected: (result) => setState(() => _currentSort = result),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: SortOption.defaultSort, child: Text('Default', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: SortOption.az, child: Text('A - Z', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: SortOption.za, child: Text('Z - A', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: SortOption.newest, child: Text('Newest', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: SortOption.oldest, child: Text('Oldest', style: TextStyle(color: Colors.white))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: displayMovies.isEmpty
                      ? Center(child: Text('No movies found.', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)))
                      : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: displayMovies.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayMovies.length) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
                      }

                      final movie = displayMovies[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailsScreen(movie: movie)));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: movie.posterUrl.isNotEmpty
                                      ? Image.network(
                                    movie.posterUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF14161F), child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.white.withOpacity(0.2))),
                                  )
                                      : Container(color: const Color(0xFF14161F), width: double.infinity, child: Icon(Icons.movie_rounded, size: 40, color: Colors.white.withOpacity(0.2))),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              movie.title,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.9), height: 1.2),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}