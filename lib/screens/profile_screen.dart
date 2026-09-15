// lib/screens/profile_screen.dart
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

  // Local default state
  String _favoriteGenre = 'Sci-Fi';

  void _showEditProfileDialog(String currentName) async {
    final TextEditingController nameController = TextEditingController(text: currentName);
    final TextEditingController genreController = TextEditingController(text: _favoriteGenre);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1C24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Your Username',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE50914))),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: genreController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Favorite Genre',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE50914))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'genre': genreController.text.trim(),
                });
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        if (result['name']!.isNotEmpty) {
          // Changed to set with merge: true to ensure the document is created if missing!
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_authService.currentUserUid)
              .set({
            'username': result['name']
          }, SetOptions(merge: true));
        }
        if (result['genre']!.isNotEmpty) {
          setState(() {
            _favoriteGenre = result['genre']!;
          });
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _logOut() async {
    await _authService.logOut();
    // Navigation is handled automatically by AuthGate sending user back to LoginScreen
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
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            final userName = userData?['username'] ?? 'Film Enthusiast';
            final userEmail = userData?['email'] ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Profile Picture & Edit Badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: Color(0xFF1A1C24),
                        child: Icon(Icons.person, size: 54, color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => _showEditProfileDialog(userName),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE50914),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // User Name & Email
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Favorite Genre: $_favoriteGenre',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // Navigation List Items
                  _buildProfileOption(
                    icon: Icons.history_rounded,
                    title: 'Viewing History',
                    subtitle: 'Recent trailers and titles browsed',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1C24),
                          title: const Text('Viewing History', style: TextStyle(color: Colors.white)),
                          content: const Text('Your recently browsed titles will appear here.', style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close', style: TextStyle(color: Color(0xFFE50914))),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.tune_rounded,
                    title: 'App Preferences',
                    subtitle: 'Language, region & cache',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1C24),
                          title: const Text('App Preferences', style: TextStyle(color: Colors.white)),
                          content: const Text('Dark theme and TMDB data caching are active by default.', style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close', style: TextStyle(color: Color(0xFFE50914))),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  _buildProfileOption(
                    icon: Icons.info_outline_rounded,
                    title: 'About FilmBase',
                    subtitle: 'Version 1.0.0 (SDP Project)',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'FilmBase',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'Powered by the TMDB API',
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // NEW: Log Out Button
                  _buildProfileOption(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    subtitle: 'Sign out of FilmBase',
                    iconColor: Colors.redAccent,
                    onTap: _logOut,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFFE50914),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
        onTap: onTap,
      ),
    );
  }
}