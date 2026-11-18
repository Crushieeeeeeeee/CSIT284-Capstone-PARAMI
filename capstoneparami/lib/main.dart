import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/home_shell.dart';

// After `flutterfire configure`, import 'firebase_options.dart' and use:
// await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const IntramsApp());
}

class IntramsApp extends StatelessWidget {
  const IntramsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intrams Scoreboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepOrange),
      home: const HomeShell(),
    );
  }
}