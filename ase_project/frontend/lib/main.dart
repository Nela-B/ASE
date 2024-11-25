import 'package:ase_project/screens/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ASE Project',
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}



// // Call createTask on the TaskService instance
    //taskService.createTask("Sample Title", "Sample Description", "High");