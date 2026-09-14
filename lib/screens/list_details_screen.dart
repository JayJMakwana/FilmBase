// lib/screens/list_details_screen.dart
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_details_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _movies = List.from(widget.movies);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() async {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
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
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<List<Movie>> _fetchMoreMovies(int page) async {
    final text = widget.listName;
    if (_isGenre(text)) {
      return await _apiService.searchMoviesByGenre(text, page: page);
    } else if (int.tryParse(text) != null) {
      return await _apiService.searchMoviesByYear(text, page: page);
    } else if (['English', 'Spanish', 'Hindi', 'Korean', 'Japanese', 'French', 'German', 'English Hits', 'Hindi Blockbusters', 'Korean Cinema', 'French Cinema'].contains(text)) {
      String langQuery = text.replaceAll(' Hits', '').replaceAll(' Blockbusters', '').replaceAll(' Cinema', '');
      return await _apiService.searchMoviesByLanguage(langQuery, page: page);
    } else if (['Award Winners', 'Top Box Office', 'Critically Acclaimed', 'Indie Darlings', 'Based on a Book'].contains(text)) {
      return await _apiService.fetchCuratedCollection(text, page: page);
    } else if (text == 'Top Rated' || text == 'Top Rated Masterpieces') {
      return await _apiService.fetchTopRatedMovies(page: page);
    } else if (text == 'Now Playing' || text == 'Now Playing in Theaters') {
      return await _apiService.fetchNowPlayingMovies(page: page);
    } else if (text == 'Upcoming' || text == 'Coming Soon') {
      return await _apiService.fetchUpcomingMovies(page: page);
    } else if (text == 'Trending Now') {
      return await _apiService.fetchTrendingMovies(page: page);
    } else if (text == 'Popular' || text == 'Popular on FilmBase') {
      return await _apiService.fetchPopularMovies(page: page);
    } else {
      return await _apiService.searchMovies(text, page: page);
    }
  }

  bool _isGenre(String name) {
    final map = {
      'action': 28, 'adventure': 12, 'animation': 16, 'comedy': 35,
      'crime': 80, 'documentary': 99, 'drama': 18, 'family': 10751,
      'fantasy': 14, 'history': 36, 'horror': 27, 'music': 10402,
      'mystery': 9648, 'romance': 10749, 'science fiction': 878,
      'sci-fi': 878, 'thriller': 53, 'war': 10752, 'western': 37
    };
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

    int columns = 2;
    if (screenWidth > 1400) {
      columns = 7;
    } else if (screenWidth > 1100) {
      columns = 6;
    } else if (screenWidth > 900) {
      columns = 5;
    } else if (screenWidth > 700) {
      columns = 4;
    } else if (screenWidth > 500) {
      columns = 3;
    } else {
      columns = 2;
    }

    double childAspectRatio = 0.55;
    if (columns >= 5) {
      childAspectRatio = 0.6;
    } else if (columns == 4) {
      childAspectRatio = 0.57;
    } else if (columns == 3) {
      childAspectRatio = 0.58;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.listName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _movies.isEmpty
          ? const Center(
        child: Text(
          'No movies found.',
          style: TextStyle(color: Colors.white70),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsScreen(movie: movie),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: movie.posterUrl.isNotEmpty
                              ? Image.network(
                            movie.posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: const Color(0xFF1A1C24),
                                  child: const Icon(Icons.broken_image, size: 40, color: Colors.white38),
                                ),
                          )
                              : Container(
                            color: const Color(0xFF1A1C24),
                            width: double.infinity,
                            child: const Icon(Icons.movie, size: 40, color: Colors.white38),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            ),
        ],
      ),
    );
  }
}