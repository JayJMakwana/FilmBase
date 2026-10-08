// lib/screens/friends_screen.dart
import 'dart:ui';
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
  final FocusNode _searchFocus = FocusNode();

  List<DocumentSnapshot> _searchResults = [];
  bool _isSearching = false;

  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool get _isSearchMode => _searchFocus.hasFocus || _searchController.text.isNotEmpty;

  void _searchUser() async {
    setState(() => _isSearching = true);
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final result = await _dbService.searchUserByUsername(query);
      setState(() => _searchResults = result.docs);
    }
    setState(() => _isSearching = false);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() => _searchResults.clear());
  }

  void _sendRequest(String targetUid) async {
    final currentUid = _authService.currentUserUid;
    if (currentUid != null) {
      await _dbService.sendFriendRequest(currentUid, targetUid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend request sent!'), backgroundColor: Colors.green));
      }
    }
  }

  void _confirmUnfriend(String currentUid, String friendUid, String friendName) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: FilmbaseColors.elevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: FilmbaseColors.hairline)),
          title: const Text('Unfriend User', style: TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to remove $friendName from your friends list?', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                Navigator.pop(context);
                await _dbService.unfriend(currentUid, friendUid);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User unfriended'), backgroundColor: Colors.redAccent));
              },
              child: const Text('Unfriend', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
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
                        // --- 1. SEARCH BAR ---
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocus,
                                style: const TextStyle(color: FilmbaseColors.text),
                                decoration: InputDecoration(
                                  hintText: 'Search username...',
                                  suffixIcon: _isSearchMode
                                      ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                                    onPressed: _clearSearch,
                                  )
                                      : null,
                                ),
                                onSubmitted: (_) => _searchUser(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: FilmbaseColors.accent,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: FilmbaseColors.accent.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
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

                        // --- 2. DYNAMIC CONTENT AREA ---
                        if (_isSearchMode) ...[
                          Text('SEARCH RESULTS', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.1)),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _searchResults.isEmpty && !_isSearching && _searchController.text.isNotEmpty
                                ? Center(child: Text('No users found.', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))))
                                : ListView.builder(
                              physics: const BouncingScrollPhysics(),
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
                        ] else ...[
                          _buildTabBubbles(),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _buildActiveTabContent(currentUid),
                          ),
                        ],
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

  // --- TAB BUBBLE WIDGETS ---
  Widget _buildTabBubbles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBubble('Friends', 0),
        const SizedBox(width: 8),
        _buildBubble('Sent', 1),
        const SizedBox(width: 8),
        _buildBubble('Incoming', 2),
      ],
    );
  }

  Widget _buildBubble(String text, int index) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? FilmbaseColors.accent : FilmbaseColors.elevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? FilmbaseColors.accent : FilmbaseColors.hairline),
            boxShadow: isActive ? [BoxShadow(color: FilmbaseColors.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // --- CONTENT SWITCHER ---
  Widget _buildActiveTabContent(String currentUid) {
    switch (_selectedTab) {
      case 0: return _buildFriendsList(currentUid);
      case 1: return _buildSentRequests(currentUid);
      case 2: return _buildIncomingRequests(currentUid);
      default: return const SizedBox.shrink();
    }
  }

  // --- 0: FRIENDS LIST ---
  Widget _buildFriendsList(String currentUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.getFriendsList(currentUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading friends', style: TextStyle(color: Colors.redAccent)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No friends added yet', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontStyle: FontStyle.italic)));
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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FriendListsScreen(friendUid: friendUid, friendName: friendName))),
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
                    leading: CircleAvatar(
                      backgroundColor: FilmbaseColors.elevated,
                      backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                      child: profileUrl == null ? const Icon(Icons.person_rounded, color: Colors.white) : null,
                    ),
                    title: Text(friendName, style: const TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.bold)),
                    subtitle: Text('Tap to view shared lists', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove_rounded, color: Colors.white30),
                      onPressed: () => _confirmUnfriend(currentUid, friendUid, friendName),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- 1: SENT REQUESTS ---
  Widget _buildSentRequests(String currentUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.getSentRequests(currentUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading requests', style: TextStyle(color: Colors.redAccent)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No requests sent', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontStyle: FontStyle.italic)));
        }

        final sentRequests = snapshot.data!.docs;
        final pendingOrRejected = sentRequests.where((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final status = data['status'] ?? 'pending';
          return status != 'accepted';
        }).toList();

        if (pendingOrRejected.isEmpty) {
          return Center(child: Text('All sent requests were accepted!', style: TextStyle(color: Colors.green.withValues(alpha: 0.6), fontStyle: FontStyle.italic)));
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: pendingOrRejected.length,
          itemBuilder: (context, index) {
            final req = pendingOrRejected[index];
            final data = req.data() as Map<String, dynamic>? ?? {};
            final targetUid = data['toUid'];
            final status = data['status'] ?? 'pending';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(targetUid).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const SizedBox.shrink();
                final targetData = userSnapshot.data!.data() as Map<String, dynamic>?;
                final targetName = targetData?['username'] ?? 'Unknown User';
                final profileUrl = targetData?['profileImageUrl'];

                return SurfaceCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: FilmbaseColors.elevated,
                      backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                      child: profileUrl == null ? const Icon(Icons.person_rounded, color: Colors.white54) : null,
                    ),
                    title: Text(targetName, style: const TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.w600)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == 'rejected' ? Colors.red.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: status == 'rejected' ? Colors.red.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        status == 'rejected' ? 'Rejected' : 'Pending',
                        style: TextStyle(
                          color: status == 'rejected' ? Colors.red : Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- 2: INCOMING REQUESTS ---
  Widget _buildIncomingRequests(String currentUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.getIncomingRequests(currentUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading requests', style: TextStyle(color: Colors.redAccent)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No pending requests', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontStyle: FontStyle.italic)));
        }

        final requests = snapshot.data!.docs;
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final data = req.data() as Map<String, dynamic>? ?? {};
            final requestId = req.id;
            final senderUid = data['fromUid'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(senderUid).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const SizedBox.shrink();
                final senderData = userSnapshot.data!.data() as Map<String, dynamic>?;
                final profileUrl = senderData?['profileImageUrl'];

                return SurfaceCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
                    leading: CircleAvatar(
                      backgroundColor: FilmbaseColors.elevated,
                      backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                      child: profileUrl == null ? const Icon(Icons.person_rounded, color: Colors.white54) : null,
                    ),
                    title: Text(senderData?['username'] ?? 'Unknown User', style: const TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.w600)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                          onPressed: () => _dbService.acceptFriendRequest(requestId, currentUid, senderUid),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 28),
                          onPressed: () => _dbService.declineFriendRequest(requestId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}