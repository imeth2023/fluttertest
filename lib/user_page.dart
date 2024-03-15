import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _newPasswordController = TextEditingController();
  String _profileImagePath = ''; // To store the profile image path

  @override
  void initState() {
    super.initState();
    _loadProfileImagePath();
  }

  void _loadProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profileImagePath') ?? '';
    });
  }

  void _signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // It's better to remove the flag entirely on sign out.
    await prefs.remove('profileImagePath'); // Remove the profile image path as well
    Navigator.of(context).pushNamed('/login');
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

  Future<void> _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String path = appDir.path;
      final File newImage = await File(image.path).copy('$path/profile_picture.png');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', newImage.path);

      setState(() {
        _profileImagePath = newImage.path;
      });
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
              if (_profileImagePath.isNotEmpty)
                Center(
                  child: CircleAvatar(
                    backgroundImage: FileImage(File(_profileImagePath)),
                    radius: 60,
                  ),
                ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _takePicture,
                  child: Text('Take Profile Picture'),
                ),
              ),
              SizedBox(height: 20),
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
