// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //  Create a new custom list (e.g., "Favorites", "Watch Later")
  Future<void> createList(String userId, String listName) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('lists')
        .add({
      'listName': listName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  //  Add a movie to a specific list
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
      'posterPath': movie.posterUrl, // <--- CHANGED to posterUrl
      'rating': movie.voteAverage,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  //  Stream a user's lists (Stream allows the UI to update instantly when a new list is added)
  Stream<QuerySnapshot> getUserLists(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('lists')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  //  Search for a user by username to send a request
  Future<QuerySnapshot> searchUserByUsername(String username) async {
    return await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  //  Send a friend request
  Future<void> sendFriendRequest(String currentUserId, String targetUserId) async {
    // Prevent sending request to yourself
    if (currentUserId == targetUserId) return;

    // Check if a request already exists or if they are already friends
    await _db.collection('friend_requests').add({
      'fromUid': currentUserId,
      'toUid': targetUserId,
      'status': 'pending', // pending, accepted, declined
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  //  Accept a friend request
  Future<void> acceptFriendRequest(String requestId, String currentUserId, String friendUid) async {
    // Update request status to accepted
    await _db.collection('friend_requests').doc(requestId).update({'status': 'accepted'});

    // Add each other to respective friend collections
    await _db.collection('users').doc(currentUserId).collection('friends').doc(friendUid).set({
      'friendUid': friendUid,
      'addedAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(friendUid).collection('friends').doc(currentUserId).set({
      'friendUid': currentUserId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  //  Stream incoming friend requests for the current user
  Stream<QuerySnapshot> getIncomingRequests(String userId) {
    return _db
        .collection('friend_requests')
        .where('toUid', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  //  Stream accepted friends list
  Stream<QuerySnapshot> getFriendsList(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots();
  }
  //  Stream movies inside a specific list
  Stream<QuerySnapshot> getMoviesInList(String userId, String listId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listId)
        .collection('movies')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
  // Remove a movie from a specific list
  Future<void> removeMovieFromList(String userId, String listId, String movieId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listId)
        .collection('movies')
        .doc(movieId)
        .delete();
  }
}