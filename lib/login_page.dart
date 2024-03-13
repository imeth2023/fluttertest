import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginWithEmail() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in. Please check your credentials.')),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        await _auth.signInWithCredential(credential);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google. Please try again.')),
      );
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email address to reset your password.')),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A password reset link has been sent to your email.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send password reset email. Please check your email address and try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
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
                onPressed: _loginWithEmail,
                child: Text('Login'),
              ),
              ElevatedButton(
                onPressed: _loginWithGoogle,
                child: Text('Sign in with Google'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white), // Button color
                  foregroundColor: MaterialStateProperty.all(Colors.black), // Text color
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/signup'),
                child: Text("Don't have an account? Sign up"),
              ),
              TextButton(
                onPressed: _resetPassword,
                child: Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
