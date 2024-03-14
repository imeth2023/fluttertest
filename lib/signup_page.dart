import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _auth.createUserWithEmailAndPassword(
                  email: _emailController.text,
                  password: _passwordController.text,
                );
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                // Handle error
              }
            },
            child: Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
