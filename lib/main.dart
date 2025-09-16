import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'package:buraco/screens/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://gkojbuafztegbjgqlaht.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdrb2pidWFmenRlZ2JqZ3FsYWh0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5ODg2ODEsImV4cCI6MjA3MzU2NDY4MX0.qovnaZIhOaxl1CWpecenl0vWZC57XVtiSPbdYzTfZcI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Meu App', home: Login());
  }
}
