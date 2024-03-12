import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _newPasswordController = TextEditingController();

  void _signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // It's better to remove the flag entirely on sign out.
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _changePassword() async {
    if (_newPasswordController.text.isNotEmpty) {
      try {
        await _auth.currentUser?.updatePassword(_newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password successfully updated.')),
        );
        _newPasswordController.clear();
      } catch (error) {
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password. Please re-authenticate or try again later.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a new password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${user?.email}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
