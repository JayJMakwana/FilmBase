// lib/screens/watchlist_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'user_list_movies_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  void _showCreateListDialog() {
    final TextEditingController listController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1C24),
          title: const Text('Create New List', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: listController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'e.g. Weekend Binge',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE50914))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
              onPressed: () {
                final listName = listController.text.trim();
                if (listName.isNotEmpty) {
                  _dbService.createList(_authService.currentUserUid!, listName);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Assigns specific icons/colors to default list names to keep your UI looking nice
  IconData _getIconForList(String listName) {
    if (listName.toLowerCase().contains('fav')) return Icons.favorite;
    if (listName.toLowerCase().contains('watch later')) return Icons.schedule;
    if (listName.toLowerCase().contains('watched')) return Icons.visibility;
    return Icons.list_alt_rounded;
  }

  Color _getColorForList(String listName) {
    if (listName.toLowerCase().contains('fav')) return Colors.redAccent;
    if (listName.toLowerCase().contains('watch later')) return Colors.orangeAccent;
    if (listName.toLowerCase().contains('watched')) return Colors.blueAccent;
    return Colors.white54;
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _authService.currentUserUid;

    if (currentUid == null) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Library', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getUserLists(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("You don't have any lists yet.\nTap 'New List' to start!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54)),
            );
          }

          final lists = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final listDoc = lists[index];
              final listName = listDoc['listName'];
              final listId = listDoc.id;

              return _buildFolderCard(
                  context,
                  listName,
                  listId,
                  currentUid,
                  _getIconForList(listName),
                  _getColorForList(listName)
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateListDialog,
        backgroundColor: const Color(0xFFE50914),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFolderCard(BuildContext context, String title, String listId, String userId, IconData icon, Color iconColor) {
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
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserListMoviesScreen(
                userId: userId,
                listId: listId,
                listName: title,
              ),
            ),
          );
        },
      ),
    );
  }
}