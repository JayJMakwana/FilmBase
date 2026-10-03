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
      backgroundColor: const Color(0xFF0A0C10),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE50914).withOpacity(0.08)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
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
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64.0 : 20.0, vertical: 12.0),
                    child: isDesktop
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: Image.network(
                              movie.posterUrl,
                              width: 260,
                              height: 390,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 260, height: 390, child: Icon(Icons.broken_image_rounded, size: 80, color: Colors.white38)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(child: _buildMovieDetailsContent(context)),
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(17),
                              child: Image.network(
                                movie.posterUrl,
                                width: 200,
                                height: 300,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const SizedBox(width: 200, height: 300, child: Icon(Icons.broken_image_rounded, size: 80, color: Colors.white38)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildMovieDetailsContent(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final currentUid = AuthService().currentUserUid;
          if (currentUid == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to save movies.')));
            return;
          }
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => SaveMovieSheet(movie: movie, userId: currentUid),
          );
        },
        backgroundColor: const Color(0xFFE50914),
        elevation: 4,
        icon: const Icon(Icons.bookmark_add_rounded, color: Colors.white, size: 22),
        label: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildMovieDetailsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(movie.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5, height: 1.1)),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(movie.releaseDate, style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w500)),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 6),
                  Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Synopsis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Text(movie.overview, style: TextStyle(fontSize: 15, height: 1.6, color: Colors.white.withOpacity(0.7))),
        const SizedBox(height: 28),

        FutureBuilder<List<Cast>>(
          future: _apiService.getMovieCast(movie.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
            final castList = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Cast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: castList.length,
                  itemBuilder: (context, index) {
                    final cast = castList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('${cast.name} — ${cast.character}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w500)),
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