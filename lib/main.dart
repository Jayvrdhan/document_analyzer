import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bfnaixwfawttbagbotrk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmbmFpeHdmYXd0dGJhZ2JvdHJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzNzIxODYsImV4cCI6MjA5NDk0ODE4Nn0.CIqbmB0bDJos9hnqIkSsm4xsfQmeRL78jtoflugWkh4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Document Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}