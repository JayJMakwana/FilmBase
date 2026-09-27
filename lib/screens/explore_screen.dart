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
            // Search Bar
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
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Search Movies, TV shows',
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
              showSeeMore: false, // Disables the See More button for this section
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection({
    required BuildContext context,
    required String title,
    required List<String> items,
    required bool isGenre,
    bool showSeeMore = true, // Added flag to conditionally render See More
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
            ...items.map((item) => _buildBubble(context, item, sectionTitle: title, isGenre: isGenre)),
            if (showSeeMore)
              _buildBubble(context, 'See more', sectionTitle: title, isSeeMore: true),
          ],
        ),
      ],
    );
  }

  // Consolidated navigation logic
  Future<void> _fetchAndNavigate(BuildContext context, String listTitle, Future<List<Movie>> Function() fetchMethod) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final movies = await fetchMethod();

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListDetailsScreen(
            listName: listTitle,
            movies: movies,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load $listTitle movies')),
      );
    }
  }

  void _showCategorySearchDialog(
      BuildContext context, {
        required String title,
        required String hintText,
        TextInputType keyboardType = TextInputType.text,
        required void Function(String query) onSearch,
      }) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade900.withOpacity(0.5)),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextField(
          controller: textController,
          keyboardType: keyboardType,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF121212),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade800),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(dialogCtx);
              onSearch(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final value = textController.text.trim();
              if (value.isNotEmpty) {
                Navigator.pop(dialogCtx);
                onSearch(value);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context, String text, {required String sectionTitle, bool isSeeMore = false, bool isGenre = false}) {
    final apiService = ApiService();

    return InkWell(
      onTap: () {
        if (isSeeMore) {
          // Trigger the specific search dialog based on the category section
          if (sectionTitle == 'Top Genres') {
            _showCategorySearchDialog(
              context,
              title: 'Search by Genre',
              hintText: 'e.g., Mystery, Fantasy, Western...',
              onSearch: (genre) => _fetchAndNavigate(context, 'Genre: $genre', () => apiService.searchMoviesByGenre(genre)),
            );
          } else if (sectionTitle == 'Release Year') {
            _showCategorySearchDialog(
              context,
              title: 'Search by Year',
              hintText: 'Enter year (e.g., 1999, 2015)',
              keyboardType: TextInputType.number,
              onSearch: (year) => _fetchAndNavigate(context, 'Year: $year', () => apiService.searchMoviesByYear(year)),
            );
          } else if (sectionTitle == 'Language & Region') {
            _showCategorySearchDialog(
              context,
              title: 'Search by Language',
              hintText: 'e.g., Japanese, French, Telugu...',
              onSearch: (lang) => _fetchAndNavigate(context, 'Language: $lang', () => apiService.searchMoviesByLanguage(lang)),
            );
          } else if (sectionTitle == 'Curated Collections') {
            _showCategorySearchDialog(
              context,
              title: 'Search Collections',
              hintText: 'e.g., Superheroes, Classic Sci-Fi...',
              onSearch: (query) => _fetchAndNavigate(context, 'Collection: $query', () => apiService.searchMovies(query)), // Fallback to general search
            );
          }
          return; // Exit after showing dialog
        }

        // Standard Bubble Click Logic
        _fetchAndNavigate(context, text, () {
          if (isGenre) {
            return apiService.searchMoviesByGenre(text);
          } else if (int.tryParse(text) != null) {
            return apiService.searchMoviesByYear(text);
          } else if (['English', 'Spanish', 'Hindi', 'Korean', 'Japanese', 'French', 'German'].contains(text)) {
            return apiService.searchMoviesByLanguage(text);
          } else if (['Award Winners', 'Top Box Office', 'Critically Acclaimed', 'Indie Darlings', 'Based on a Book'].contains(text)) {
            return apiService.fetchCuratedCollection(text);
          } else {
            return apiService.searchMovies(text);
          }
        });
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