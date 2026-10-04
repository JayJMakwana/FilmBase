// lib/screens/friend_lists_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme/filmbase_theme.dart';
import '../widgets/cinematic_chrome.dart';
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
      backgroundColor: FilmbaseColors.canvas,
      body: Stack(
        children: [
          const GlowBackdrop(color: Color(0xFF0055FF)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(title: "$friendName's Lists", showBack: true),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: dbService.getUserLists(friendUid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF0055FF)));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_off_rounded, size: 80, color: Colors.white.withValues(alpha: 0.1)),
                              const SizedBox(height: 16),
                              Text("$friendName hasn't created any lists yet.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7))),
                            ],
                          ),
                        );
                      }

                      final lists = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: lists.length,
                        itemBuilder: (context, index) {
                          final listDoc = lists[index];
                          final listName = listDoc['listName'];
                          final listId = listDoc.id;

                          return SurfaceCard(
                            margin: const EdgeInsets.only(bottom: 14),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => UserListMoviesScreen(userId: friendUid, listId: listId, listName: listName)));
                            },
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(color: const Color(0xFF0055FF).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                                  child: const Icon(Icons.folder_shared_rounded, color: Color(0xFF0055FF), size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(listName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: FilmbaseColors.text, letterSpacing: 0.2)),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.3), size: 16),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
