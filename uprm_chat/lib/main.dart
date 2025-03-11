import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uprm_chat/services/auth/auth_gate.dart';
import 'package:uprm_chat/themes/uprm_green.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp()); //Runs the App
}

class MyApp extends StatelessWidget {
  // Our Root Widget
  const MyApp({super.key}); // Contructor for the Class

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: greenMode,
    );
  }
}
