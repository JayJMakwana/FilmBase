// lib/screens/friends_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
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
      backgroundColor: const Color(0xFF0E1017),
      appBar: AppBar(
        title: const Text('Friends & Sharing', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1C24),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar for Users
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search username...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1A1C24),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Results
            if (_searchResults.isNotEmpty) ...[
              const Text('Search Results', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final userData = _searchResults[index].data() as Map<String, dynamic>;
                    final targetUid = userData['uid'];

                    if (targetUid == currentUid) return const SizedBox.shrink(); // Don't show yourself

                    return ListTile(
                      title: Text(userData['username'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(userData['email'], style: const TextStyle(color: Colors.white54)),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add, color: Color(0xFFE50914)),
                        onPressed: () => _sendRequest(targetUid),
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: Colors.white24),
            ],

            const SizedBox(height: 10),
            const Text('Incoming Requests', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Incoming Requests Stream
            Expanded(
              flex: 1,
              child: StreamBuilder<QuerySnapshot>(
                stream: _dbService.getIncomingRequests(currentUid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No pending requests', style: TextStyle(color: Colors.white38)));
                  }

                  final requests = snapshot.data!.docs;
                  return ListView.builder(
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

                          return ListTile(
                            title: Text(senderData?['username'] ?? 'Unknown User', style: const TextStyle(color: Colors.white)),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () => _dbService.acceptFriendRequest(requestId, currentUid, senderUid),
                              child: const Text('Accept', style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            const Text('Your Friends', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Friends List Stream
            Expanded(
              flex: 1,
              child: StreamBuilder<QuerySnapshot>(
                stream: _dbService.getFriendsList(currentUid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No friends added yet', style: TextStyle(color: Colors.white38)));
                  }

                  final friends = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friendUid = friends[index]['friendUid'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(friendUid).get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) return const SizedBox.shrink();
                          final friendData = userSnapshot.data!.data() as Map<String, dynamic>?;
                          final friendName = friendData?['username'] ?? 'User';

                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE50914),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(friendName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: const Text('Tap to view shared lists', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FriendListsScreen(
                                    friendUid: friendUid,
                                    friendName: friendName,
                                  ),
                                ),
                              );
                            },
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