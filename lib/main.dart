import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:buraco/screens/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://dprpskfdigdgnvgrnugv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwcnBza2ZkaWdkZ252Z3JudWd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0Mjg3NDMsImV4cCI6MjA3MDAwNDc0M30.pHUJyAYV6UEmyQfCZesQiaA4x70di4J1c2SHQ3wW8tc',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App',
      home: Login(),
    );
  }
}
