import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geminichatbot/Screens/authScreen.dart';
import 'package:geminichatbot/Screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If user is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // If user is not logged in
        return const AuthScreen();
      },
    );
  }
}