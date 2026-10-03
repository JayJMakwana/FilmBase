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
      backgroundColor: const Color(0xFF0A0C10),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0055FF).withOpacity(0.08)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('Friends & Sharing', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search Bar for Users
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search username...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                            filled: true,
                            fillColor: const Color(0xFF14161F),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50914),
                          borderRadius: BorderRadius.circular(14),
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

                  // Search Results
                  if (_searchResults.isNotEmpty) ...[
                    Text('Search Results', style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final userData = _searchResults[index].data() as Map<String, dynamic>;
                          final targetUid = userData['uid'];
                          if (targetUid == currentUid) return const SizedBox.shrink();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(color: const Color(0xFF14161F), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.06))),
                            child: ListTile(
                              title: Text(userData['username'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(userData['email'], style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                              trailing: IconButton(
                                icon: const Icon(Icons.person_add_rounded, color: Color(0xFFE50914)),
                                onPressed: () => _sendRequest(targetUid),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 24),
                  ],

                  const Text('Incoming Requests', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Expanded(
                    flex: 1,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _dbService.getIncomingRequests(currentUid),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No pending requests', style: TextStyle(color: Colors.white.withOpacity(0.3))));
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

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(color: const Color(0xFF14161F), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
                                  child: ListTile(
                                    title: Text(senderData?['username'] ?? 'Unknown User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                  const Text('Your Friends', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Expanded(
                    flex: 1,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _dbService.getFriendsList(currentUid),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No friends added yet', style: TextStyle(color: Colors.white.withOpacity(0.3))));
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

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(color: const Color(0xFF14161F), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.06))),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    leading: const CircleAvatar(backgroundColor: Color(0xFF0055FF), child: Icon(Icons.person_rounded, color: Colors.white)),
                                    title: Text(friendName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    subtitle: Text('Tap to view shared lists', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                                    trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 16),
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => FriendListsScreen(friendUid: friendUid, friendName: friendName)));
                                    },
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
    );
  }
}