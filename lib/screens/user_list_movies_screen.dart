// lib/screens/user_list_movies_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/movie.dart';
import '../theme/filmbase_theme.dart';
import '../widgets/cinematic_chrome.dart';
import 'movie_details_screen.dart';

enum MovieSortOption { newest, oldest, az, za }

class UserListMoviesScreen extends StatefulWidget {
  final String userId;
  final String listId;
  final String listName;

  const UserListMoviesScreen({
    super.key,
    required this.userId,
    required this.listId,
    required this.listName,
  });

  @override
  State<UserListMoviesScreen> createState() => _UserListMoviesScreenState();
}

class _UserListMoviesScreenState extends State<UserListMoviesScreen> {
  final DatabaseService _dbService = DatabaseService();
  MovieSortOption _currentSort = MovieSortOption.newest;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columns = screenWidth > 1400 ? 7 : screenWidth > 1100 ? 6 : screenWidth > 900 ? 5 : screenWidth > 700 ? 4 : screenWidth > 500 ? 3 : 2;
    double childAspectRatio = columns >= 5 ? 0.6 : columns == 4 ? 0.57 : columns == 3 ? 0.58 : 0.55;

    return Scaffold(
      backgroundColor: FilmbaseColors.canvas,
      body: Stack(
        children: [
          const GlowBackdrop(fromRight: false),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: widget.listName,
                  showBack: true,
                  actions: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: FilmbaseColors.hairline),
                      ),
                      child: PopupMenuButton<MovieSortOption>(
                        icon: const Icon(Icons.sort_rounded, color: FilmbaseColors.text, size: 20),
                        color: FilmbaseColors.elevated,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: FilmbaseColors.hairline)),
                        onSelected: (result) => setState(() => _currentSort = result),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: MovieSortOption.newest, child: Text('Recently Added', style: TextStyle(color: FilmbaseColors.text))),
                          const PopupMenuItem(value: MovieSortOption.oldest, child: Text('Oldest Added', style: TextStyle(color: FilmbaseColors.text))),
                          const PopupMenuItem(value: MovieSortOption.az, child: Text('A - Z', style: TextStyle(color: FilmbaseColors.text))),
                          const PopupMenuItem(value: MovieSortOption.za, child: Text('Z - A', style: TextStyle(color: FilmbaseColors.text))),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _dbService.getMoviesInList(widget.userId, widget.listId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.movie_filter_rounded, size: 80, color: Colors.white.withValues(alpha: 0.1)),
                              const SizedBox(height: 16),
                              Text('No movies in ${widget.listName}.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8))),
                            ],
                          ),
                        );
                      }

                      List<QueryDocumentSnapshot> sortedMovies = snapshot.data!.docs.toList();
                      sortedMovies.sort((a, b) {
                        final dataA = a.data() as Map<String, dynamic>;
                        final dataB = b.data() as Map<String, dynamic>;
                        final titleA = (dataA['title'] ?? '').toString().toLowerCase();
                        final titleB = (dataB['title'] ?? '').toString().toLowerCase();
                        final timeA = (dataA['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                        final timeB = (dataB['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

                        switch (_currentSort) {
                          case MovieSortOption.az: return titleA.compareTo(titleB);
                          case MovieSortOption.za: return titleB.compareTo(titleA);
                          case MovieSortOption.oldest: return timeA.compareTo(timeB);
                          case MovieSortOption.newest: default: return timeB.compareTo(timeA);
                        }
                      });

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: sortedMovies.length,
                        itemBuilder: (context, index) {
                          final movieData = sortedMovies[index].data() as Map<String, dynamic>;
                          String rawPath = movieData['posterPath'] ?? '';
                          String imageUrl = rawPath.startsWith('http') ? rawPath : 'https://image.tmdb.org/t/p/w500$rawPath';

                          return GestureDetector(
                            onTap: () async {
                              final int movieId = movieData['movieId'] ?? 0;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                barrierColor: Colors.black54,
                                builder: (_) => const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent)),
                              );

                              final ApiService apiService = ApiService();
                              Movie? fullMovie = await apiService.fetchMovieDetails(movieId);

                              if (!context.mounted) return;
                              Navigator.pop(context);

                              if (fullMovie != null) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailsScreen(movie: fullMovie)));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not load movie details.')));
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: FilmbaseColors.hairline),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.38), blurRadius: 14, offset: const Offset(0, 7)),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: FilmbaseColors.surface,
                                    child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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