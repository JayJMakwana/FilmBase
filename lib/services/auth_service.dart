// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream to listen to auth state changes (logged in vs logged out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user ID safely
  String? get currentUserUid => _auth.currentUser?.uid;

  // Sign Up with Email, Password, and a Username
  Future<UserCredential?> signUpWithEmail(String email, String password, String username) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      // Create the user's public profile document in Firestore
      if (credential.user != null) {
        await _db.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return credential;
    } catch (e) {
      print("Sign Up Error: $e");
      rethrow;
    }
  }

  // Log In with Email and Password
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
  }

  // Log Out
  Future<void> logOut() async {
    await _auth.signOut();
  }
}