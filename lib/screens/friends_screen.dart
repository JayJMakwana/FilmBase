// lib/screens/friends_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/filmbase_theme.dart';
import '../widgets/cinematic_chrome.dart';
import 'friend_lists_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<DocumentSnapshot> _searchResults = [];
  bool _isSearching = false;

  void _searchUser() async {
    setState(() => _isSearching = true);
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final result = await _dbService.searchUserByUsername(query);
      setState(() {
        _searchResults = result.docs;
      });
    }
    setState(() => _isSearching = false);
  }

  void _sendRequest(String targetUid) async {
    final currentUid = _authService.currentUserUid;
    if (currentUid != null) {
      await _dbService.sendFriendRequest(currentUid, targetUid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _authService.currentUserUid ?? '';

    return Scaffold(
      backgroundColor: FilmbaseColors.canvas,
      body: Stack(
        children: [
          const GlowBackdrop(color: Color(0xFF0055FF), fromRight: false),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(title: 'Friends & Sharing', showBack: true),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: FilmbaseColors.text),
                                decoration: const InputDecoration(
                                  hintText: 'Search username...',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: FilmbaseColors.accent,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(color: FilmbaseColors.accent.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: IconButton(
                                onPressed: _isSearching ? null : _searchUser,
                                icon: _isSearching
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.search_rounded, color: Colors.white),
                                padding: const EdgeInsets.all(14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        if (_searchResults.isNotEmpty) ...[
                          Text('SEARCH RESULTS', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.1)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final userData = _searchResults[index].data() as Map<String, dynamic>;
                                final targetUid = userData['uid'];
                                final profileUrl = userData['profileImageUrl'];

                                if (targetUid == currentUid) return const SizedBox.shrink();

                                return SurfaceCard(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: FilmbaseColors.elevated,
                                      backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                                      child: profileUrl == null ? const Icon(Icons.person_rounded, color: Colors.white54) : null,
                                    ),
                                    title: Text(userData['username'], style: const TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.bold)),
                                    subtitle: Text(userData['email'], style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.person_add_rounded, color: FilmbaseColors.accent),
                                      onPressed: () => _sendRequest(targetUid),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(color: Colors.white12, height: 24),
                        ],

                        const Text('Incoming Requests', style: TextStyle(color: FilmbaseColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),

                        Expanded(
                          flex: 1,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _dbService.getIncomingRequests(currentUid),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(child: Text('No pending requests', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))));
                              }

                              final requests = snapshot.data!.docs;
                              return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  final req = requests[index];
                                  final requestId = req.id;
                                  final senderUid = req['fromUid'];

                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('users').doc(senderUid).get(),
                                    builder: (context, userSnapshot) {
                                      if (!userSnapshot.hasData) return const SizedBox.shrink();
                                      final senderData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                      final profileUrl = senderData?['profileImageUrl'];

                                      return SurfaceCard(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: FilmbaseColors.elevated,
                                            backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                                            child: profileUrl == null ? const Icon(Icons.person_rounded, color: Colors.white54) : null,
                                          ),
                                          title: Text(senderData?['username'] ?? 'Unknown User', style: const TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.w600)),
                                          trailing: ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                            onPressed: () => _dbService.acceptFriendRequest(requestId, currentUid, senderUid),
                                            child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const Divider(color: Colors.white12, height: 24),
                        const Text('Your Friends', style: TextStyle(color: FilmbaseColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),

                        Expanded(
                          flex: 1,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _dbService.getFriendsList(currentUid),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(child: Text('No friends added yet', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))));
                              }

                              final friends = snapshot.data!.docs;
                              return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: friends.length,
                                itemBuilder: (context, index) {
                                  final friendUid = friends[index]['friendUid'];

                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('users').doc(friendUid).get(),
                                    builder: (context, userSnapshot) {
                                      if (!userSnapshot.hasData) return const SizedBox.shrink();
                                      final friendData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                      final friendName = friendData?['username'] ?? 'User';
                                      final profileUrl = friendData?['profileImageUrl'];

                                      return SurfaceCard(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => FriendListsScreen(friendUid: friendUid, friendName: friendName)));
                                        },
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                          leading: CircleAvatar(
                                            backgroundColor: FilmbaseColors.elevated,
                                            backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                                            child: profileUrl == null ? const Icon(Icons.person_rounded, color: Colors.white) : null,
                                          ),
                                          title: Text(friendName, style: const TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.bold)),
                                          subtitle: Text('Tap to view shared lists', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                                          trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.3), size: 16),
                                        ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}