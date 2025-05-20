// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class SignupScreen extends StatefulWidget {
//   final Function toggleView;
//   const SignupScreen({super.key, required this.toggleView});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
  
//   String name = '';
//   String email = '';
//   String password = '';
//   String error = '';
//   bool loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Register for Gemini Chat",
//           style: GoogleFonts.lato(
//             textStyle: const TextStyle(
//               color: Colors.black,
//               letterSpacing: .4,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Name field
//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (val) => val!.isEmpty ? 'Enter your name' : null,
//                 onChanged: (val) {
//                   setState(() => name = val);
//                 },
//               ),
//               const SizedBox(height: 20),
              
//               // Email field
//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (val) => val!.isEmpty ? 'Enter an email' : null,
//                 onChanged: (val) {
//                   setState(() => email = val);
//                 },
//               ),
//               const SizedBox(height: 20),
              
//               // Password field
//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (val) => val!.length < 6 ? 'Password must be 6+ chars long' : null,
//                 onChanged: (val) {
//                   setState(() => password = val);
//                 },
//               ),
//               const SizedBox(height: 20),
              
//               // Register button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(50),
//                 ),
//                 onPressed: loading ? null : () async {
//                   if (_formKey.currentState!.validate()) {
//                     setState(() => loading = true);
//                     try {
//                       // Create user with email & password
//                       UserCredential result = await _auth.createUserWithEmailAndPassword(
//                         email: email,
//                         password: password,
//                       );
                      
//                       // Add user details to Firestore
//                       await _firestore.collection('users').doc(result.user!.uid).set({
//                         'name': name,
//                         'email': email,
//                         'createdAt': DateTime.now().toIso8601String(),
//                       });
                      
//                     } on FirebaseAuthException catch (e) {
//                       setState(() {
//                         error = e.message ?? 'Failed to register';
//                         loading = false;
//                       });
//                     }
//                   }
//                 },
//                 child: loading 
//                   ? const CircularProgressIndicator() 
//                   : const Text('Register', style: TextStyle(fontSize: 18)),
//               ),
//               const SizedBox(height: 12),
              
//               // Switch to login
//               TextButton(
//                 onPressed: () => widget.toggleView(),
//                 child: const Text('Already have an account? Login'),
//               ),
              
//               // Error text
//               Text(
//                 error,
//                 style: const TextStyle(color: Colors.red, fontSize: 14),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  final Function toggleView;
  const SignupScreen({super.key, required this.toggleView});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String error = '';
  String successMessage = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register for Gemini Chat",
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (successMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            successMessage,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                  onChanged: (val) {
                    setState(() => name = val);
                  },
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val!.isEmpty) return 'Enter an email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                ),
                const SizedBox(height: 20),
 
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (val) => val!.length < 6 ? 'Password must be 6+ character long' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (val) => val != password ? 'Passwords do not match' : null,
                  onChanged: (val) {
                    setState(() => confirmPassword = val);
                  },
                ),
                const SizedBox(height: 20),
            
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: loading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                        error = '';
                        successMessage = '';
                      });
                      try {
                        UserCredential result = await _auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        
                        await _firestore.collection('users').doc(result.user!.uid).set({
                          'name': name,
                          'email': email,
                          'createdAt': DateTime.now().toIso8601String(),
                        });
                        
                        await _auth.signOut();
                        
                        // Show success message
                        setState(() {
                          loading = false;
                          successMessage = 'Registration successful! Please login to continue.';
                          // Clear form fields
                          name = '';
                          email = '';
                          password = '';
                          confirmPassword = '';
                          _formKey.currentState!.reset();
                        });
                        
                        Future.delayed(const Duration(seconds: 3), () {
                          widget.toggleView();
                        });
                        
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          error = e.message ?? 'Failed to register';
                          loading = false;
                        });
                      }
                    }
                  },
                  child: loading 
                    ? const CircularProgressIndicator() 
                    : const Text('Register', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 12),
                
                // Switch to login
                TextButton(
                  onPressed: () => widget.toggleView(),
                  child: const Text('Already have an account? Login'),
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
      ),
    );
  }
}