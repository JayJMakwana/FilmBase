import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'theme/filmbase_theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for the current platform (Web in your case)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FilmBaseApp());
}

class FilmBaseApp extends StatelessWidget {
  const FilmBaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilmBase',

      debugShowCheckedModeBanner: false,
      theme: FilmbaseTheme.dark,
      home: const AuthGate(),
    );
  }
}