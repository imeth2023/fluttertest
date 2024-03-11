import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
  await _auth.signInWithEmailAndPassword(
    email: _emailController.text,
    password: _passwordController.text,
  );
  Navigator.pushReplacementNamed(context, '/home');
} catch (e) {
  // Handle error by showing a SnackBar with a message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('The username or password is incorrect. Please try again.'),
      backgroundColor: Colors.red, // Optional: to highlight the error
    ),
  );
}

            },
            child: Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
            child: Text('Don\'t have an account? Sign up'),
          ),
        ],
      ),
    );
  }
}
