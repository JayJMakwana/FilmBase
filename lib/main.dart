import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
void main() {
  runApp(const FilmBaseApp());
}

class FilmBaseApp extends StatelessWidget {
  const FilmBaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilmBase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1016),
        primaryColor: const Color(0xFFE50914),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          secondary: Color(0xFFFFB800),
          surface: Color(0xFF1A1C24),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(), // Loads the screen from your new file
    );
  }
}