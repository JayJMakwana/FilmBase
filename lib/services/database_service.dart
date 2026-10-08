// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new custom list
  Future<void> createList(String userId, String listName) async {
    await _db.collection('users').doc(userId).collection('lists').add({
      'listName': listName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Add a movie to a specific list
  Future<void> addMovieToList(String userId, String listId, Movie movie) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listId)
        .collection('movies')
        .doc(movie.id.toString())
        .set({
      'movieId': movie.id,
      'title': movie.title,
      'posterPath': movie.posterUrl,
      'rating': movie.voteAverage,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream a user's lists
  Stream<QuerySnapshot> getUserLists(String userId) {
    return _db.collection('users').doc(userId).collection('lists').orderBy('createdAt', descending: true).snapshots();
  }

  // Search for a user by username
  Future<QuerySnapshot> searchUserByUsername(String username) async {
    return await _db.collection('users').where('username', isEqualTo: username).get();
  }

  // --- FRIEND MANAGEMENT ---

  // Send a friend request
  Future<void> sendFriendRequest(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) return;

    await _db.collection('friend_requests').add({
      'fromUid': currentUserId,
      'toUid': targetUserId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Accept a friend request
  Future<void> acceptFriendRequest(String requestId, String currentUserId, String friendUid) async {
    await _db.collection('friend_requests').doc(requestId).update({'status': 'accepted'});

    await _db.collection('users').doc(currentUserId).collection('friends').doc(friendUid).set({
      'friendUid': friendUid,
      'addedAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(friendUid).collection('friends').doc(currentUserId).set({
      'friendUid': currentUserId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Decline a friend request
  Future<void> declineFriendRequest(String requestId) async {
    await _db.collection('friend_requests').doc(requestId).update({'status': 'rejected'});
  }

  // Unfriend someone
  Future<void> unfriend(String currentUserId, String friendUid) async {
    // Remove from both users' friend collections
    await _db.collection('users').doc(currentUserId).collection('friends').doc(friendUid).delete();
    await _db.collection('users').doc(friendUid).collection('friends').doc(currentUserId).delete();

    // Clean up request history so they can re-add each other in the future
    final q1 = await _db.collection('friend_requests').where('fromUid', isEqualTo: currentUserId).where('toUid', isEqualTo: friendUid).get();
    for (var doc in q1.docs) { await doc.reference.delete(); }

    final q2 = await _db.collection('friend_requests').where('fromUid', isEqualTo: friendUid).where('toUid', isEqualTo: currentUserId).get();
    for (var doc in q2.docs) { await doc.reference.delete(); }
  }

  // Stream incoming friend requests
  Stream<QuerySnapshot> getIncomingRequests(String userId) {
    return _db.collection('friend_requests').where('toUid', isEqualTo: userId).where('status', isEqualTo: 'pending').snapshots();
  }

  // Stream sent friend requests (Pending & Rejected)
  Stream<QuerySnapshot> getSentRequests(String userId) {
    return _db.collection('friend_requests').where('fromUid', isEqualTo: userId).snapshots();
  }

  // Stream accepted friends list
  Stream<QuerySnapshot> getFriendsList(String userId) {
    return _db.collection('users').doc(userId).collection('friends').snapshots();
  }

  // --- MOVIE LIST MANAGEMENT ---

  // Stream movies inside a specific list
  Stream<QuerySnapshot> getMoviesInList(String userId, String listId) {
    return _db.collection('users').doc(userId).collection('lists').doc(listId).collection('movies').orderBy('addedAt', descending: true).snapshots();
  }

  // Remove a movie from a specific list
  Future<void> removeMovieFromList(String userId, String listId, String movieId) async {
    await _db.collection('users').doc(userId).collection('lists').doc(listId).collection('movies').doc(movieId).delete();
  }
}