import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geminichatbot/Provider/themeProvider.dart';
import 'package:geminichatbot/Screens/authWrapper.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  String apiKey = dotenv.env['API_KEY'] ?? '';

  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // print("API+KEY ${apiKey}");

  Gemini.init(apiKey: apiKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Gemini App Developed by pravesh mahaur',
            themeMode: themeProvider.themeMode, // Apply Theme Mode
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.lightBlue
              // colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
            ),
            debugShowCheckedModeBanner: false,
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blueGrey,
            ),
            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}