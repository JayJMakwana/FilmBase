// lib/screens/watchlist_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
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
  ListSortOption _currentSort = ListSortOption.newest; // Default sort state

  void _showCreateListDialog() {
    final TextEditingController listController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1C24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  void _showRenameListDialog(String userId, String listId, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1C24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rename List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'List Name',
              labelStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE50914))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('lists')
                      .doc(listId)
                      .update({'listName': newName});
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteListDialog(String userId, String listId, String listName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1C24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete "$listName"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                try {
                  final listRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('lists')
                      .doc(listId);

                  // 1. Delete all movies inside this list to prevent orphaned documents
                  final moviesSnapshot = await listRef.collection('movies').get();
                  for (var doc in moviesSnapshot.docs) {
                    await doc.reference.delete();
                  }

                  // 2. Delete the actual list document
                  await listRef.delete();

                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                } catch (e) {
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting list: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        actions: [
          PopupMenuButton<ListSortOption>(
            icon: const Icon(Icons.sort, color: Colors.white),
            color: const Color(0xFF1A1C24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (ListSortOption result) {
              setState(() {
                _currentSort = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ListSortOption>>[
              const PopupMenuItem<ListSortOption>(
                value: ListSortOption.newest,
                child: Text('Recently Created', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<ListSortOption>(
                value: ListSortOption.oldest,
                child: Text('Oldest First', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<ListSortOption>(
                value: ListSortOption.az,
                child: Text('A - Z', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<ListSortOption>(
                value: ListSortOption.za,
                child: Text('Z - A', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
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

          // Convert Firestore docs to a standard list so we can apply custom sorting
          List<QueryDocumentSnapshot> sortedLists = snapshot.data!.docs.toList();

          // Apply local sorting logic
          sortedLists.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            final nameA = (dataA['listName'] ?? '').toString().toLowerCase();
            final nameB = (dataB['listName'] ?? '').toString().toLowerCase();

            final timeA = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final timeB = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

            switch (_currentSort) {
              case ListSortOption.az:
                return nameA.compareTo(nameB);
              case ListSortOption.za:
                return nameB.compareTo(nameA);
              case ListSortOption.oldest:
                return timeA.compareTo(timeB);
              case ListSortOption.newest:
              default:
                return timeB.compareTo(timeA); // Descending (Newest first)
            }
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedLists.length,
            itemBuilder: (context, index) {
              final listDoc = sortedLists[index];
              final data = listDoc.data() as Map<String, dynamic>;

              final listName = data['listName'] ?? 'Unnamed List';
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

        // Replaced simple icon with a PopupMenuButton for Delete/Rename
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          color: const Color(0xFF1A1C24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'rename') {
              _showRenameListDialog(userId, listId, title);
            } else if (value == 'delete') {
              _showDeleteListDialog(userId, listId, title);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.white70),
                  SizedBox(width: 8),
                  Text('Rename', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
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