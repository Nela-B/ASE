import 'package:flutter/material.dart';
import 'screens/login_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASE Project',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}



// // Call createTask on the TaskService instance
    //taskService.createTask("Sample Title", "Sample Description", "High");