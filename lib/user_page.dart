import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  void _changePassword() async {
    try {
      await user?.updatePassword(newPasswordController.text).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Password successfully updated."),
        ));
        newPasswordController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Password can't be changed" + error.toString()),
        ));
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred. Please try again later."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user?.email}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
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
    );
  }
}
