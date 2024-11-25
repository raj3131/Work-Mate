import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import the HomeScreen
import 'login_screen.dart'; // Import the LoginScreen

class HomeOrLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomeScreen(); // User is logged in
        } else {
          return LoginScreen(); // User is not logged in
        }
      },
    );
  }
}
