// lib/screens/profile_screen.dart
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/filmbase_theme.dart';
import '../widgets/cinematic_chrome.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String _favoriteGenre = 'Sci-Fi';

  // Premium Vector Preset Avatars
  final List<String> _presetAvatars = [
    'https://api.dicebear.com/9.x/micah/png?seed=Felix&backgroundColor=E50914', // Red
    'https://api.dicebear.com/9.x/micah/png?seed=Aneka&backgroundColor=0055FF', // Blue
    'https://api.dicebear.com/9.x/micah/png?seed=John&backgroundColor=14161F',  // Dark
    'https://api.dicebear.com/9.x/micah/png?seed=Jane&backgroundColor=FFB703',  // Yellow
    'https://api.dicebear.com/9.x/micah/png?seed=Alex&backgroundColor=FF2A54',  // Pink
    'https://api.dicebear.com/9.x/micah/png?seed=Sam&backgroundColor=00F0FF',   // Cyan
    'https://api.dicebear.com/9.x/micah/png?seed=Jordan&backgroundColor=FF5D00',// Orange
    'https://api.dicebear.com/9.x/micah/png?seed=Taylor&backgroundColor=8A2BE2',// Purple
  ];

  // --- NEW: Cinematic Avatar Picker Sheet ---
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 380,
            decoration: const BoxDecoration(
              color: FilmbaseColors.elevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: FilmbaseColors.hairline, width: 1)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose Avatar', style: TextStyle(color: FilmbaseColors.text, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: _presetAvatars.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(context); // Close sheet instantly

                          // Save to Firestore
                          await FirebaseFirestore.instance.collection('users').doc(_authService.currentUserUid).set(
                            {'profileImageUrl': _presetAvatars[index]},
                            SetOptions(merge: true),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: CircleAvatar(
                            backgroundColor: FilmbaseColors.canvas,
                            backgroundImage: NetworkImage(_presetAvatars[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
            backgroundColor: FilmbaseColors.elevated,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: FilmbaseColors.hairline)),
            title: const Text('Edit Profile', style: TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: FilmbaseColors.text),
                  decoration: InputDecoration(
                    labelText: 'Your Username',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: genreController,
                  style: const TextStyle(color: FilmbaseColors.text),
                  decoration: InputDecoration(
                    labelText: 'Favorite Genre',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: FilmbaseColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
      backgroundColor: FilmbaseColors.canvas,
      body: Stack(
        children: [
          const GlowBackdrop(color: Color(0xFF0055FF), fromRight: false),
          SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: FilmbaseColors.accent));

                  final userData = snapshot.data?.data() as Map<String, dynamic>?;
                  final userName = userData?['username'] ?? 'Film Enthusiast';
                  final userEmail = userData?['email'] ?? '';
                  final profileImageUrl = userData?['profileImageUrl']; // Fetch the URL

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: FilmbaseColors.text, letterSpacing: -0.6)),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                          decoration: BoxDecoration(
                            color: FilmbaseColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: FilmbaseColors.hairline),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  // TRIGGER SHEET WHEN AVATAR IS TAPPED
                                  GestureDetector(
                                    onTap: _showAvatarPicker,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: FilmbaseColors.accent.withValues(alpha: 0.4), width: 2)),
                                      child: CircleAvatar(
                                        radius: 54,
                                        backgroundColor: FilmbaseColors.elevated,
                                        backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                                        child: profileImageUrl == null ? const Icon(Icons.person_rounded, size: 60, color: Colors.white54) : null,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showEditProfileDialog(userName),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: FilmbaseColors.accent, shape: BoxShape.circle, border: Border.all(color: FilmbaseColors.canvas, width: 3)),
                                      child: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: FilmbaseColors.text)),
                              const SizedBox(height: 6),
                              Text(userEmail, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: FilmbaseColors.hairline)),
                                child: Text('Favorite Genre: $_favoriteGenre', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

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
                                  backgroundColor: FilmbaseColors.elevated,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: FilmbaseColors.hairline)),
                                  title: const Text('App Preferences', style: TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.bold)),
                                  content: const Text('Dark theme and TMDB data caching are active by default.', style: TextStyle(color: Colors.white70)),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: FilmbaseColors.accent)))],
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
                        const SizedBox(height: 8),
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

  Widget _buildProfileOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Color iconColor = FilmbaseColors.accent}) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: FilmbaseColors.text, fontWeight: FontWeight.w700, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.3), size: 16),
      ),
    );
  }
}