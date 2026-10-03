// lib/screens/profile_screen.dart
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String _favoriteGenre = 'Sci-Fi';

  void _showEditProfileDialog(String currentName) async {
    final TextEditingController nameController = TextEditingController(text: currentName);
    final TextEditingController genreController = TextEditingController(text: _favoriteGenre);

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF14161F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
            title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Your Username',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE50914))),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: genreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Favorite Genre',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE50914))),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () => Navigator.pop(context, {'name': nameController.text.trim(), 'genre': genreController.text.trim()}),
                child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      try {
        if (result['name']!.isNotEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(_authService.currentUserUid).set({'username': result['name']}, SetOptions(merge: true));
        }
        if (result['genre']!.isNotEmpty) setState(() => _favoriteGenre = result['genre']!);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _logOut() async => await _authService.logOut();

  @override
  Widget build(BuildContext context) {
    final currentUid = _authService.currentUserUid;
    if (currentUid == null) return const Scaffold(body: Center(child: Text("Please log in.")));

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
            child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));

                  final userData = snapshot.data?.data() as Map<String, dynamic>?;
                  final userName = userData?['username'] ?? 'Film Enthusiast';
                  final userEmail = userData?['email'] ?? '';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text('Profile', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                        ),
                        const SizedBox(height: 30),

                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.1), width: 2)),
                              child: const CircleAvatar(radius: 54, backgroundColor: Color(0xFF14161F), child: Icon(Icons.person_rounded, size: 60, color: Colors.white54)),
                            ),
                            GestureDetector(
                              onTap: () => _showEditProfileDialog(userName),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFFE50914), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0A0C10), width: 3)),
                                child: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(userEmail, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                          child: Text('Favorite Genre: $_favoriteGenre', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 40),

                        _buildProfileOption(
                          icon: Icons.tune_rounded,
                          title: 'App Preferences',
                          subtitle: 'Language, region & cache',
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black54,
                              builder: (context) => BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: AlertDialog(
                                  backgroundColor: const Color(0xFF14161F),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
                                  title: const Text('App Preferences', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  content: const Text('Dark theme and TMDB data caching are active by default.', style: TextStyle(color: Colors.white70)),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Color(0xFFE50914))))],
                                ),
                              ),
                            );
                          },
                        ),
                        _buildProfileOption(
                          icon: Icons.info_outline_rounded,
                          title: 'About FilmBase',
                          subtitle: 'Version 1.0.0 (SDP Project)',
                          onTap: () {
                            showAboutDialog(context: context, applicationName: 'FilmBase', applicationVersion: '1.0.0', applicationLegalese: 'Powered by the TMDB API');
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildProfileOption(
                          icon: Icons.logout_rounded,
                          title: 'Log Out',
                          subtitle: 'Sign out of FilmBase',
                          iconColor: Colors.redAccent,
                          onTap: _logOut,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Color iconColor = const Color(0xFFE50914)}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF14161F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 16),
        onTap: onTap,
      ),
    );
  }
}