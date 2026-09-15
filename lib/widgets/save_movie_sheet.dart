// lib/widgets/save_movie_sheet.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/database_service.dart';

class SaveMovieSheet extends StatefulWidget {
  final Movie movie;
  final String userId;

  const SaveMovieSheet({super.key, required this.movie, required this.userId});

  @override
  State<SaveMovieSheet> createState() => _SaveMovieSheetState();
}

class _SaveMovieSheetState extends State<SaveMovieSheet> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _newListController = TextEditingController();

  void _createNewList() {
    if (_newListController.text.trim().isNotEmpty) {
      _dbService.createList(widget.userId, _newListController.text.trim());
      _newListController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _toggleMovieInList(String listId, String listName, bool isAlreadySaved) async {
    if (isAlreadySaved) {
      await _dbService.removeMovieFromList(widget.userId, listId, widget.movie.id.toString());
    } else {
      await _dbService.addMovieToList(widget.userId, listId, widget.movie);
    }

    if (mounted) {
      Navigator.pop(context); // Close the sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAlreadySaved ? 'Removed from $listName' : 'Saved to $listName'),
          backgroundColor: isAlreadySaved ? Colors.redAccent : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1C24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Save to...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Create New List Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newListController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'New list name...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF0E1017),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _createNewList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),

            // Stream of User's Existing Lists
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _dbService.getUserLists(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
                  }
                  if (snapshot.hasError) return const Text('Error loading lists');

                  final lists = snapshot.data!.docs;
                  if (lists.isEmpty) {
                    return const Center(
                      child: Text('No lists yet. Create one above!', style: TextStyle(color: Colors.white54)),
                    );
                  }

                  return ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      final listDoc = lists[index];
                      final listName = listDoc['listName'];
                      final listId = listDoc.id;

                      // NEW: Check if this specific movie is inside this list
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userId)
                            .collection('lists')
                            .doc(listId)
                            .collection('movies')
                            .doc(widget.movie.id.toString())
                            .snapshots(),
                        builder: (context, movieSnapshot) {
                          // If the document exists, the movie is already saved!
                          bool isSaved = movieSnapshot.hasData && movieSnapshot.data!.exists;

                          return ListTile(
                            leading: Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: isSaved ? const Color(0xFFE50914) : Colors.white70
                            ),
                            title: Text(listName, style: const TextStyle(color: Colors.white)),
                            trailing: Icon(
                                isSaved ? Icons.check_circle : Icons.add_circle_outline,
                                color: isSaved ? const Color(0xFFE50914) : Colors.white70
                            ),
                            onTap: () => _toggleMovieInList(listId, listName, isSaved),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}