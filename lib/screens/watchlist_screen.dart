// lib/screens/watchlist_screen.dart
import 'package:flutter/material.dart';
import 'list_details_screen.dart';
import '../models/movie.dart'; // Added to allow the empty List<Movie>

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Library', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Temporarily set counts to 0 since we are passing empty lists
          _buildFolderCard(context, 'Favorites', Icons.favorite, 0, Colors.redAccent),
          _buildFolderCard(context, 'Watched', Icons.visibility, 0, Colors.blueAccent),
          _buildFolderCard(context, 'Watch Later', Icons.schedule, 0, Colors.orangeAccent),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          const Text('Custom Lists', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          _buildFolderCard(context, 'Best Sci-Fi of 2020s', Icons.list_alt_rounded, 0, Colors.white54),
          _buildFolderCard(context, 'Weekend Binge', Icons.list_alt_rounded, 0, Colors.white54),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Future: Open a popup to type a new list name
        },
        backgroundColor: const Color(0xFFE50914),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFolderCard(BuildContext context, String title, IconData icon, int itemCount, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        subtitle: Text('$itemCount movies', style: const TextStyle(color: Colors.white54, fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListDetailsScreen(
                listName: title,
                movies: const [], // Compiles safely and shows the empty state!
              ),
            ),
          );
        },
      ),
    );
  }
}