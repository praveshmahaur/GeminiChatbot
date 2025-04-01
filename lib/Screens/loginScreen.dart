import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  final Function toggleView;
  const LoginScreen({super.key, required this.toggleView});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login to Gemini Chat",
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              color: Colors.black,
              letterSpacing: .4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              const SizedBox(height: 20),
              
              // Password field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Password must be 6+ chars long' : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              const SizedBox(height: 20),
              
              // Login button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: loading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    try {
                      await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        error = e.message ?? 'Failed to sign in';
                        loading = false;
                      });
                    }
                  }
                },
                child: loading 
                  ? const CircularProgressIndicator() 
                  : const Text('Login', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 12),
              
              // Switch to signup
              TextButton(
                onPressed: () => widget.toggleView(),
                child: const Text('Need an account? Register'),
              ),
              
              // Error text
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}