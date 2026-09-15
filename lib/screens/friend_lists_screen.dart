// lib/screens/friend_lists_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'user_list_movies_screen.dart';

class FriendListsScreen extends StatelessWidget {
  final String friendUid;
  final String friendName;

  const FriendListsScreen({
    super.key,
    required this.friendUid,
    required this.friendName,
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1017),
      appBar: AppBar(
        title: Text("$friendName's Lists", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1C24),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // We pass the FRIEND'S uid here instead of our own!
        stream: dbService.getUserLists(friendUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("$friendName hasn't created any lists yet.", style: const TextStyle(color: Colors.white54)),
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

              return Card(
                color: const Color(0xFF1A1C24),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  // Using a shared folder icon to indicate it's someone else's
                  leading: const Icon(Icons.folder_shared, color: Color(0xFFE50914), size: 32),
                  title: Text(listName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  onTap: () {
                    // We reuse the exact same screen we built for ourselves!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserListMoviesScreen(
                          userId: friendUid, // Pass the friend's ID
                          listId: listId,
                          listName: listName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}