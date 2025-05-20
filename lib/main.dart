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
            title: 'Gemini App Developed by Pravesh Mahaur',
            themeMode: themeProvider.themeMode, 
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.lightBlue
              // colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
              
            ),
            debugShowCheckedModeBanner: false,
            // darkTheme: ThemeData(
            //   brightness: Brightness.dark,
            //   primarySwatch: Colors.grey
            // ),
            darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(
              primary: Color.fromARGB(255, 133, 74, 144),     
              onPrimary: Colors.white,
              secondary: Colors.white,   
              onSecondary: Colors.white,
              background: Colors.white,  
              onBackground: Colors.white,
              // surface: Colors.white,
              onSurface: Colors.white,
              error: Colors.red,
              onError: Colors.black,
              brightness: Brightness.light,
            ),
),

            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}