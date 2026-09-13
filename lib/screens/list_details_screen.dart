// lib/screens/list_details_screen.dart
import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_details_screen.dart';

class ListDetailsScreen extends StatelessWidget {
  final String listName;
  final List<Movie> movies;

  const ListDetailsScreen({
    super.key,
    required this.listName,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Improved responsive columns calculation for web and mobile
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

    // Adjust childAspectRatio based on number of columns for better proportions
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
        title: Text(listName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: movies.isEmpty
          ? const Center(
        child: Text(
          'No movies found.',
          style: TextStyle(color: Colors.white70),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

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
    );
  }
}
