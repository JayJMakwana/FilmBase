// lib/screens/my_lists_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/filmbase_theme.dart';
import '../widgets/cinematic_chrome.dart';
import 'user_list_movies_screen.dart';

class MyListsScreen extends StatelessWidget {
  const MyListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final DatabaseService dbService = DatabaseService();
    final currentUid = authService.currentUserUid;

    if (currentUid == null) return const Scaffold(body: Center(child: Text("Please log in.")));

    return Scaffold(
      backgroundColor: FilmbaseColors.canvas,
      body: Stack(
        children: [
          const GlowBackdrop(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(title: 'My Watchlists', showBack: true),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: dbService.getUserLists(currentUid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open_rounded, size: 80, color: Colors.white.withValues(alpha: 0.1)),
                              const SizedBox(height: 16),
                              Text("You haven't created any lists yet.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8))),
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => UserListMoviesScreen(userId: currentUid, listId: listId, listName: listName)));
                            },
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(color: FilmbaseColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                                  child: const Icon(Icons.folder_special_rounded, color: FilmbaseColors.accent, size: 24),
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
