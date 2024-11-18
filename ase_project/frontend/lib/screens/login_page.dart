import 'package:ase_project/components/my_button.dart';
import 'package:ase_project/components/my_textfield.dart';
import 'package:ase_project/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

void signUserIn() async {
  try {
    // Validate email and password
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      // Show a message if the fields are empty
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Champs requis'),
              content: const Text('Veuillez entrer un email et un mot de passe.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      return;
    }

    // Show loading indicator
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // Try signing in with Firebase
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Close the loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Navigate to home page if successful
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  } on FirebaseAuthException catch (e) {
    // Close the loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Handle Firebase error
    String errorMessage = '';
    if (e.code == 'user-not-found') {
      errorMessage = 'Aucun utilisateur trouvé avec cet email';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Mot de passe incorrect';
    } else {
      errorMessage = 'Une erreur est survenue';
    }

    // Show error dialog
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erreur de connexion'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[300],
    body: Column(children: [
      const SizedBox(height: 50),

      //logo
      const Icon(
        Icons.lock,
        size: 100,
      ),

      const SizedBox(height: 50),

      //Message
      Text(
        'Welcome back you\'ve been missed!',
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 16,
        ),
      ),

      const SizedBox(height: 25),

      //Email field
      MyTextfield(
        controller: emailController,
        hintText: 'Email',
        obscureText: false,
      ),

      const SizedBox(height: 10),

      //Password field
      MyTextfield(
        controller: passwordController,
        hintText: 'Password',
        obscureText: true,
      ),

      const SizedBox(height: 10),

      //forgot password
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Forgot Password?',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),

      const SizedBox(height: 25),

      //sign in button
      MyButton(
        onTap: () {
          signUserIn();
        },
      ),
    ]),
  );
}
}