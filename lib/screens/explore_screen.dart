// lib/screens/explore_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/movie.dart';
import 'search_screen.dart';
import 'list_details_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Explore', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar - Now routes to the SearchScreen
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1C24),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const TextField(
                  enabled: false, // Disables keyboard here so we route to SearchScreen instead
                  decoration: InputDecoration(
                    hintText: 'Search movies, TV shows, actors...',
                    hintStyle: TextStyle(color: Colors.white38),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
                    suffixIcon: Icon(Icons.mic_none_rounded, color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildCategorySection(
              context: context,
              title: 'Top Genres',
              items: ['Action', 'Comedy', 'Drama', 'Sci-Fi', 'Horror', 'Thriller', 'Romance', 'Animation'],
              isGenre: true,
            ),
            const SizedBox(height: 28),

            _buildCategorySection(
              context: context,
              title: 'Release Year',
              items: ['2026', '2025', '2024', '2023', '2020', '2010', '2000', 'Classics'],
              isGenre: false,
            ),
            const SizedBox(height: 28),

            _buildCategorySection(
              context: context,
              title: 'Language & Region',
              items: ['English', 'Spanish', 'Hindi', 'Korean', 'Japanese', 'French', 'German'],
              isGenre: false,
            ),
            const SizedBox(height: 28),

            _buildCategorySection(
              context: context,
              title: 'Curated Collections',
              items: ['Award Winners', 'Top Box Office', 'Critically Acclaimed', 'Indie Darlings', 'Based on a Book'],
              isGenre: false,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Notice we now pass context so we can navigate
  Widget _buildCategorySection({
    required BuildContext context,
    required String title,
    required List<String> items,
    required bool isGenre,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: [
            ...items.map((item) => _buildBubble(context, item, isGenre: isGenre)),
            _buildBubble(context, 'See more', isSeeMore: true),
          ],
        ),
      ],
    );
  }

  Widget _buildBubble(BuildContext context, String text, {bool isSeeMore = false, bool isGenre = false}) {
    final apiService = ApiService();

    return InkWell(
      onTap: () async {
        if (isSeeMore) return; // Optional: handle "See more" differently later

        // 1. Show a loading dialog while we fetch the data
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        try {
          // 2. Fetch movies based on whether it's a genre search or general search
          final List<Movie> movies;

          if (isGenre) {
            movies = await apiService.searchMoviesByGenre(text);
          } else if (int.tryParse(text) != null) {
            movies = await apiService.searchMoviesByYear(text);
          } else {
            movies = await apiService.searchMovies(text);
          }

          // 3. Remove the loading dialog
          if (!context.mounted) return;
          Navigator.pop(context);

          // 4. Push to your List Details grid screen with the fetched data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListDetailsScreen(
                listName: text,
                movies: movies,
              ),
            ),
          );
        } catch (e) {
          // Remove loading dialog on error
          if (!context.mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load $text movies')),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSeeMore ? Colors.transparent : const Color(0xFF1A1C24),
          border: Border.all(
            color: isSeeMore ? const Color(0xFFE50914) : Colors.white12,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSeeMore ? const Color(0xFFE50914) : Colors.white70,
                fontSize: 14,
                fontWeight: isSeeMore ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (isSeeMore) ...[
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFFE50914)),
            ]
          ],
        ),
      ),
    );
  }
}
