// lib/screens/movie_details_screen.dart
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/cast.dart';
import '../services/api_service.dart';
import '../widgets/save_movie_sheet.dart';
import '../services/auth_service.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;
  final ApiService _apiService = ApiService();

  MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1017),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 64.0 : 16.0,
          vertical: 12.0,
        ),
        child: isDesktop
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side: Static Uncropped Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                movie.posterUrl,
                width: 260,
                height: 390,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const SizedBox(
                  width: 260,
                  height: 390,
                  child: Icon(Icons.broken_image, size: 80, color: Colors.white38),
                ),
              ),
            ),
            const SizedBox(width: 40),
            // Right Side: Details and Dynamic Cast List
            Expanded(
              child: _buildMovieDetailsContent(context),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mobile View: Centered Poster
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  movie.posterUrl,
                  width: 200,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(
                    width: 200,
                    height: 300,
                    child: Icon(Icons.broken_image, size: 80, color: Colors.white38),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildMovieDetailsContent(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final currentUid = AuthService().currentUserUid;

          if (currentUid == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to save movies.')),
            );
            return;
          }

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => SaveMovieSheet(
              movie: movie,
              userId: currentUid,
            ),
          );
        },
        backgroundColor: const Color(0xFFE50914),
        icon: const Icon(Icons.bookmark_add, color: Colors.white),
        label: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMovieDetailsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              movie.releaseDate,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Synopsis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          movie.overview,
          style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.white70),
        ),
        const SizedBox(height: 24),

        // Dynamic Cast List Section
        FutureBuilder<List<Cast>>(
          future: _apiService.getMovieCast(movie.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final castList = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Cast',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: castList.length,
                  itemBuilder: (context, index) {
                    final cast = castList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '${cast.name} — ${cast.character}',
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}