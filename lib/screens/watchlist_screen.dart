// lib/screens/watchlist_screen.dart
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/filmbase_theme.dart';
import '../widgets/cinematic_chrome.dart';
import 'user_list_movies_screen.dart';

enum ListSortOption { newest, oldest, az, za }

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  ListSortOption _currentSort = ListSortOption.newest;

  void _showCreateListDialog() {
    final TextEditingController listController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: FilmbaseColors.elevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: FilmbaseColors.hairline),
            ),
            title: const Text('Create New List', style: TextStyle(color: FilmbaseColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
            content: TextField(
              controller: listController,
              style: const TextStyle(color: FilmbaseColors.text, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'e.g. Weekend Binge',
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFE50914), Color(0xFFB80710)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final listName = listController.text.trim();
                    if (listName.isNotEmpty) {
                      _dbService.createList(_authService.currentUserUid!, listName);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameListDialog(String userId, String listId, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: FilmbaseColors.elevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: FilmbaseColors.hairline),
            ),
            title: const Text('Rename List', style: TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.bold)),
            content: TextField(
              controller: controller,
              style: const TextStyle(color: FilmbaseColors.text),
              decoration: InputDecoration(
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: FilmbaseColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final newName = controller.text.trim();
                  if (newName.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('users').doc(userId).collection('lists').doc(listId).update({'listName': newName});
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteListDialog(String userId, String listId, String listName) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: FilmbaseColors.elevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: FilmbaseColors.hairline),
            ),
            title: const Text('Delete List', style: TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.bold)),
            content: Text(
              'Are you sure you want to delete "$listName"?\nThis action cannot be undone.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  try {
                    final listRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('lists').doc(listId);
                    final moviesSnapshot = await listRef.collection('movies').get();
                    for (var doc in moviesSnapshot.docs) await doc.reference.delete();
                    await listRef.delete();
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  } catch (e) {
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForList(String listName) {
    if (listName.toLowerCase().contains('fav')) return Icons.favorite_rounded;
    if (listName.toLowerCase().contains('watch later')) return Icons.schedule_rounded;
    if (listName.toLowerCase().contains('watched')) return Icons.check_circle_rounded;
    if (listName.toLowerCase().contains('action')) return Icons.local_fire_department_rounded;
    return Icons.movie_filter_rounded;
  }

  Color _getColorForList(String listName) {
    if (listName.toLowerCase().contains('fav')) return const Color(0xFFFF2A54);
    if (listName.toLowerCase().contains('watch later')) return const Color(0xFFFFB703);
    if (listName.toLowerCase().contains('watched')) return const Color(0xFF00F0FF);
    if (listName.toLowerCase().contains('action')) return const Color(0xFFFF5D00);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _authService.currentUserUid;
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
                ScreenHeader(
                  title: 'My Library',
                  actions: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: FilmbaseColors.hairline),
                      ),
                      child: PopupMenuButton<ListSortOption>(
                        icon: const Icon(Icons.sort_rounded, color: FilmbaseColors.text, size: 22),
                        color: FilmbaseColors.elevated,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: FilmbaseColors.hairline)),
                        onSelected: (result) => setState(() => _currentSort = result),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: ListSortOption.newest, child: Text('Recently Created', style: TextStyle(color: FilmbaseColors.text))),
                          const PopupMenuItem(value: ListSortOption.oldest, child: Text('Oldest First', style: TextStyle(color: FilmbaseColors.text))),
                          const PopupMenuItem(value: ListSortOption.az, child: Text('A - Z', style: TextStyle(color: FilmbaseColors.text))),
                          const PopupMenuItem(value: ListSortOption.za, child: Text('Z - A', style: TextStyle(color: FilmbaseColors.text))),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _dbService.getUserLists(currentUid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.movie_creation_rounded, size: 80, color: Colors.white.withValues(alpha: 0.1)),
                              const SizedBox(height: 16),
                              Text("Your library is empty.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.9))),
                              const SizedBox(height: 8),
                              Text("Tap the button below to start curating.", style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                            ],
                          ),
                        );
                      }

                      List<QueryDocumentSnapshot> sortedLists = snapshot.data!.docs.toList();
                      sortedLists.sort((a, b) {
                        final dataA = a.data() as Map<String, dynamic>;
                        final dataB = b.data() as Map<String, dynamic>;
                        final nameA = (dataA['listName'] ?? '').toString().toLowerCase();
                        final nameB = (dataB['listName'] ?? '').toString().toLowerCase();
                        final timeA = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                        final timeB = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

                        switch (_currentSort) {
                          case ListSortOption.az: return nameA.compareTo(nameB);
                          case ListSortOption.za: return nameB.compareTo(nameA);
                          case ListSortOption.oldest: return timeA.compareTo(timeB);
                          case ListSortOption.newest: default: return timeB.compareTo(timeA);
                        }
                      });

                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                        itemCount: sortedLists.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final listDoc = sortedLists[index];
                          final data = listDoc.data() as Map<String, dynamic>;
                          final listName = data['listName'] ?? 'Unnamed List';

                          return _buildCleanCard(context, listName, listDoc.id, currentUid, _getIconForList(listName), _getColorForList(listName));
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateListDialog,
        backgroundColor: FilmbaseColors.accent,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text('New List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildCleanCard(BuildContext context, String title, String listId, String userId, IconData icon, Color iconColor) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserListMoviesScreen(userId: userId, listId: listId, listName: title)));
      },
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: FilmbaseColors.text, letterSpacing: 0.2)),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz_rounded, color: Colors.white.withValues(alpha: 0.4)),
            color: FilmbaseColors.elevated,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: FilmbaseColors.hairline)),
            onSelected: (value) {
              if (value == 'rename') _showRenameListDialog(userId, listId, title);
              else if (value == 'delete') _showDeleteListDialog(userId, listId, title);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: Colors.white70), SizedBox(width: 12), Text('Rename', style: TextStyle(color: FilmbaseColors.text))])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 18, color: Colors.redAccent), SizedBox(width: 12), Text('Delete', style: TextStyle(color: Colors.redAccent))])),
            ],
          ),
        ],
      ),
    );
  }
}
