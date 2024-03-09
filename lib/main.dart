import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure this import points to your Firebase options file
import 'login_page.dart'; // Assuming you have this file for login
import 'signup_page.dart'; // Assuming you have this file for signup
import 'home_page.dart'; // Assuming you have this file for the home page
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Demo',
      theme: ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Colors.black,
),

      home: LoginPage(), // Set LoginPage as the initial route
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
