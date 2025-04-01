import 'package:flutter/material.dart';
import 'package:geminichatbot/Screens/loginScreen.dart';
import 'package:geminichatbot/Screens/signupScreen.dart';



class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  void toggleView() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return LoginScreen(toggleView: toggleView);
    } else {
      return SignupScreen(toggleView: toggleView);
    }
  }
}