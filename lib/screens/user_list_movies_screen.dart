// lib/screens/user_list_movies_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/movie.dart';
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
  MovieSortOption _currentSort = MovieSortOption.newest; // Default sorting state

  @override
  Widget build(BuildContext context) {
    // Responsive grid logic
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
    }

    double childAspectRatio = 0.55;
    if (columns >= 5) childAspectRatio = 0.6;
    else if (columns == 4) childAspectRatio = 0.57;
    else if (columns == 3) childAspectRatio = 0.58;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1017),
      appBar: AppBar(
        title: Text(widget.listName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1C24),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<MovieSortOption>(
            icon: const Icon(Icons.sort, color: Colors.white),
            color: const Color(0xFF1A1C24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (MovieSortOption result) {
              setState(() {
                _currentSort = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MovieSortOption>>[
              const PopupMenuItem<MovieSortOption>(
                value: MovieSortOption.newest,
                child: Text('Recently Added', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<MovieSortOption>(
                value: MovieSortOption.oldest,
                child: Text('Oldest Added', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<MovieSortOption>(
                value: MovieSortOption.az,
                child: Text('A - Z', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<MovieSortOption>(
                value: MovieSortOption.za,
                child: Text('Z - A', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getMoviesInList(widget.userId, widget.listId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_filter_outlined, size: 64, color: Colors.white38),
                  const SizedBox(height: 16),
                  Text('No movies in ${widget.listName} yet.', style: const TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
            );
          }

          // Convert Firestore docs to a standard list for local sorting
          List<QueryDocumentSnapshot> sortedMovies = snapshot.data!.docs.toList();

          // Apply local sorting logic based on the user's selection
          sortedMovies.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            final titleA = (dataA['title'] ?? '').toString().toLowerCase();
            final titleB = (dataB['title'] ?? '').toString().toLowerCase();

            final timeA = (dataA['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final timeB = (dataB['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

            switch (_currentSort) {
              case MovieSortOption.az:
                return titleA.compareTo(titleB);
              case MovieSortOption.za:
                return titleB.compareTo(titleA);
              case MovieSortOption.oldest:
                return timeA.compareTo(timeB);
              case MovieSortOption.newest:
              default:
                return timeB.compareTo(timeA); // Descending (Newest first)
            }
          });

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: sortedMovies.length,
            itemBuilder: (context, index) {
              final movieData = sortedMovies[index].data() as Map<String, dynamic>;

              String rawPath = movieData['posterPath'] ?? '';
              String imageUrl = rawPath.startsWith('http')
                  ? rawPath
                  : 'https://image.tmdb.org/t/p/w500$rawPath';

              return GestureDetector(
                onTap: () async {
                  final int movieId = movieData['movieId'] ?? 0;

                  // Show a quick loading indicator while fetching fresh TMDB data
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFFE50914)),
                    ),
                  );

                  // Fetch fresh movie details from TMDB using the stored ID
                  final ApiService apiService = ApiService();
                  Movie? fullMovie = await apiService.fetchMovieDetails(movieId);

                  if (!context.mounted) return;
                  Navigator.pop(context); // Dismiss loading dialog

                  if (fullMovie != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsScreen(movie: fullMovie),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not load movie details.')),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1A1C24),
                      child: const Icon(Icons.broken_image, size: 40, color: Colors.white38),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}