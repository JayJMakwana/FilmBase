import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local profile state
  String _userName = 'Film Enthusiast';
  String _favoriteGenre = 'Sci-Fi';

  // Sample static count data (perfectly simplified to just Lists and Distinct Movies)
  final int _totalLists = 5;
  final int _distinctMovies = 38;

  // Added 'async' here so the screen can wait for the dialog to close
  void _showEditProfileDialog() async {
    final TextEditingController nameController = TextEditingController(text: _userName);
    final TextEditingController genreController = TextEditingController(text: _favoriteGenre);

    // We wait for the dialog to return a Map of the new strings
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1C24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  labelStyle: TextStyle(color: Colors.white54),
                  hintText: 'e.g. John Doe',
                  hintStyle: TextStyle(color: Colors.white24),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE50914))),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: genreController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Favorite Genre / Subgenre',
                  labelStyle: TextStyle(color: Colors.white54),
                  hintText: 'e.g. Cyberpunk, Neo-Noir, Anime',
                  hintStyle: TextStyle(color: Colors.white24),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Instead of setState here, we pop the dialog and pass the data back!
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'genre': genreController.text.trim(),
                });
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    // If the user tapped Save (meaning result isn't null), WE update the state here on the main screen
    if (result != null) {
      setState(() {
        if (result['name']!.isNotEmpty) {
          _userName = result['name']!;
        }
        if (result['genre']!.isNotEmpty) {
          _favoriteGenre = result['genre']!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
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
                  onTap: _showEditProfileDialog,
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

            // User Name & Favorite Genre Tag
            Text(
              _userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Favorite Genre: $_favoriteGenre',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Edit Profile Button
            OutlinedButton.icon(
              onPressed: _showEditProfileDialog,
              icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
              label: const Text('Edit Profile', style: TextStyle(color: Colors.white70, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 24),

            // Updated Stats Counter Row (Now perfectly balanced with 2 items)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C24),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Total Lists', '$_totalLists'),
                  Container(height: 40, width: 1, color: Colors.white12), // Divider
                  _buildStatItem('Unique Movies', '$_distinctMovies'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Navigation List Items
            _buildProfileOption(
              icon: Icons.history_rounded,
              title: 'Viewing History',
              subtitle: 'Recent trailers and titles browsed',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.tune_rounded,
              title: 'App Preferences',
              subtitle: 'Language, region & cache',
              onTap: () {},
            ),
            // Look for this block near the bottom of your ProfileScreen
            _buildProfileOption(
              icon: Icons.info_outline_rounded,
              title: 'About FilmBase',
              subtitle: 'Version 1.0.0 (SDP Project)',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'FilmBase',
                  applicationVersion: '1.0.0',
                  // UPDATED TO REFLECT YOUR NEW LIVE DATA SOURCE
                  applicationLegalese: 'Powered by the Simkl API',
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
          child: Icon(icon, color: const Color(0xFFE50914)),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
        onTap: onTap,
      ),
    );
  }
}