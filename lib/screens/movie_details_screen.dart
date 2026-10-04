// lib/screens/movie_details_screen.dart
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/cast.dart';
import '../services/api_service.dart';
import '../widgets/save_movie_sheet.dart';
import '../widgets/cinematic_chrome.dart';
import '../services/auth_service.dart';
import '../theme/filmbase_theme.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;
  final ApiService _apiService = ApiService();

  MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: FilmbaseColors.canvas,
      body: Stack(
        children: [
          const GlowBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () => Navigator.pop(context),
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
                        _buildPoster(width: 260, height: 390),
                        const SizedBox(width: 40),
                        Expanded(child: _buildMovieDetailsContent(context)),
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(child: _buildPoster(width: 210, height: 315)),
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
        backgroundColor: FilmbaseColors.accent,
        elevation: 6,
        icon: const Icon(Icons.bookmark_add_rounded, color: Colors.white, size: 22),
        label: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildPoster({required double width, required double height}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: FilmbaseColors.hairline),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 22, offset: const Offset(0, 12)),
          BoxShadow(color: FilmbaseColors.accent.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Image.network(
          movie.posterUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => SizedBox(width: width, height: height, child: const Icon(Icons.broken_image_rounded, size: 80, color: Colors.white38)),
        ),
      ),
    );
  }

  Widget _buildMovieDetailsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(movie.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: FilmbaseColors.text, letterSpacing: -0.5, height: 1.1)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(movie.releaseDate, style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: FilmbaseColors.gold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: FilmbaseColors.gold.withValues(alpha: 0.32)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: FilmbaseColors.gold, size: 16),
                  const SizedBox(width: 6),
                  Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: FilmbaseColors.gold, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: FilmbaseColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: FilmbaseColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Synopsis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: FilmbaseColors.text)),
              const SizedBox(height: 8),
              Text(movie.overview, style: TextStyle(fontSize: 15, height: 1.6, color: Colors.white.withValues(alpha: 0.72))),
            ],
          ),
        ),
        const SizedBox(height: 28),

        FutureBuilder<List<Cast>>(
          future: _apiService.getMovieCast(movie.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
            final castList = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Cast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: FilmbaseColors.text)),
                const SizedBox(height: 14),
                SizedBox(
                  height: 118,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: castList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final cast = castList[index];
                      return Container(
                        width: 132,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: FilmbaseColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: FilmbaseColors.hairline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: FilmbaseColors.accent.withValues(alpha: 0.18),
                              child: Text(
                                cast.name.isNotEmpty ? cast.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: FilmbaseColors.accent, fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(cast.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(cast.character, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, height: 1.2)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 88),
      ],
    );
  }
}
