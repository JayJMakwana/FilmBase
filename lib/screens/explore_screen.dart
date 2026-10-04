// lib/screens/explore_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/movie.dart';
import '../theme/filmbase_theme.dart';
import '../widgets/cinematic_chrome.dart';
import 'search_screen.dart';
import 'list_details_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FilmbaseColors.canvas,
      body: Stack(
        children: [
          const GlowBackdrop(color: Color(0xFF0055FF), fromRight: false),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(title: 'Explore'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: FilmbaseColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: FilmbaseColors.hairline),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 6)),
                              ],
                            ),
                            child: const TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: 'Search Movies, TV shows',
                                hintStyle: TextStyle(color: Colors.white38),
                                prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
                                suffixIcon: Icon(Icons.mic_none_rounded, color: Colors.white54),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildCategorySection(
                          context: context,
                          title: 'Top Genres',
                          items: ['Action', 'Comedy', 'Drama', 'Sci-Fi', 'Horror', 'Thriller', 'Romance', 'Animation'],
                          isGenre: true,
                        ),
                        const SizedBox(height: 32),

                        _buildCategorySection(
                          context: context,
                          title: 'Release Year',
                          items: ['2026', '2025', '2024', '2023', '2020', '2010', '2000', 'Classics'],
                          isGenre: false,
                        ),
                        const SizedBox(height: 32),

                        _buildCategorySection(
                          context: context,
                          title: 'Language & Region',
                          items: ['English', 'Spanish', 'Hindi', 'Korean', 'Japanese', 'French', 'German'],
                          isGenre: false,
                        ),
                        const SizedBox(height: 32),

                        _buildCategorySection(
                          context: context,
                          title: 'Curated Collections',
                          items: ['Award Winners', 'Top Box Office', 'Critically Acclaimed', 'Indie Darlings', 'Based on a Book'],
                          isGenre: false,
                          showSeeMore: false,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required BuildContext context,
    required String title,
    required List<String> items,
    required bool isGenre,
    bool showSeeMore = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: FilmbaseColors.text, letterSpacing: -0.2)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: [
            ...items.map((item) => _buildBubble(context, item, sectionTitle: title, isGenre: isGenre)),
            if (showSeeMore) _buildBubble(context, 'See more', sectionTitle: title, isSeeMore: true),
          ],
        ),
      ],
    );
  }

  Future<void> _fetchAndNavigate(BuildContext context, String listTitle, Future<List<Movie>> Function() fetchMethod) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent)),
    );

    try {
      final movies = await fetchMethod();
      if (!context.mounted) return;
      Navigator.pop(context);

      Navigator.push(context, MaterialPageRoute(builder: (context) => ListDetailsScreen(listName: listTitle, movies: movies)));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load $listTitle movies')));
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
      barrierColor: Colors.black54,
      builder: (dialogCtx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: FilmbaseColors.elevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: FilmbaseColors.hairline)),
          title: Text(title, style: const TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.bold, fontSize: 18)),
          content: TextField(
            controller: textController,
            keyboardType: keyboardType,
            autofocus: true,
            style: const TextStyle(color: FilmbaseColors.text),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
              fillColor: Colors.white.withValues(alpha: 0.05),
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
              child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: FilmbaseColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                final value = textController.text.trim();
                if (value.isNotEmpty) {
                  Navigator.pop(dialogCtx);
                  onSearch(value);
                }
              },
              child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context, String text, {required String sectionTitle, bool isSeeMore = false, bool isGenre = false}) {
    final apiService = ApiService();

    return InkWell(
      onTap: () {
        if (isSeeMore) {
          if (sectionTitle == 'Top Genres') {
            _showCategorySearchDialog(context, title: 'Search by Genre', hintText: 'e.g., Mystery, Fantasy, Western...', onSearch: (genre) => _fetchAndNavigate(context, 'Genre: $genre', () => apiService.searchMoviesByGenre(genre)));
          } else if (sectionTitle == 'Release Year') {
            _showCategorySearchDialog(context, title: 'Search by Year', hintText: 'Enter year (e.g., 1999, 2015)', keyboardType: TextInputType.number, onSearch: (year) => _fetchAndNavigate(context, 'Year: $year', () => apiService.searchMoviesByYear(year)));
          } else if (sectionTitle == 'Language & Region') {
            _showCategorySearchDialog(context, title: 'Search by Language', hintText: 'e.g., Japanese, French, Telugu...', onSearch: (lang) => _fetchAndNavigate(context, 'Language: $lang', () => apiService.searchMoviesByLanguage(lang)));
          } else if (sectionTitle == 'Curated Collections') {
            _showCategorySearchDialog(context, title: 'Search Collections', hintText: 'e.g., Superheroes, Classic Sci-Fi...', onSearch: (query) => _fetchAndNavigate(context, 'Collection: $query', () => apiService.searchMovies(query)));
          }
          return;
        }

        _fetchAndNavigate(context, text, () {
          if (isGenre) return apiService.searchMoviesByGenre(text);
          else if (int.tryParse(text) != null) return apiService.searchMoviesByYear(text);
          else if (['English', 'Spanish', 'Hindi', 'Korean', 'Japanese', 'French', 'German'].contains(text)) return apiService.searchMoviesByLanguage(text);
          else if (['Award Winners', 'Top Box Office', 'Critically Acclaimed', 'Indie Darlings', 'Based on a Book'].contains(text)) return apiService.fetchCuratedCollection(text);
          else return apiService.searchMovies(text);
        });
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isSeeMore ? Colors.transparent : FilmbaseColors.surface,
          border: Border.all(color: isSeeMore ? FilmbaseColors.accent : FilmbaseColors.hairline),
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSeeMore ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSeeMore ? FilmbaseColors.accent : Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: isSeeMore ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            if (isSeeMore) ...[
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: FilmbaseColors.accent),
            ]
          ],
        ),
      ),
    );
  }
}
