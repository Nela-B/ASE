import 'package:ase_project/components/my_button.dart';
import 'package:ase_project/components/my_textfield.dart';
import 'package:ase_project/screens/home_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  //text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in function
  void signUserIn(){

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(children: [
        const SizedBox(height: 50),

        //logo
        const Icon(
          Icons.lock,
          size:100,
        ),

        const SizedBox(height: 50),

        //Message
        Text(
          'Welcome back you\'ve been missed!',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,),
        ),

        const SizedBox(height: 25),

        //Username field
        MyTextfield(
          controller: usernameController,
          hintText: 'Username',
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
          onTap: (){
            signUserIn();

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage())
            );
          },
        ),

      ]),
    );
  }
}