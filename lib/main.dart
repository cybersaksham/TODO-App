// Importing Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Importing External Packages
import 'package:firebase_auth/firebase_auth.dart';

// Importing Dart Files
import './Screens/Home/homescreen.dart';
import './Screens/Authentication/auth_screen.dart';

// Importing Dart Models
import './Models/routes.dart';

void main() {
  // Starting App
  runApp(MyApp());

  // Binding in portrait mode only
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();
          if (userSnap.hasData) return HomeScreen();
          return AuthScreen();
        },
      ),
      routes: {
        Routes.home_screen: (ctx) => HomeScreen(),
        Routes.auth_screen: (ctx) => AuthScreen(),
      },
    );
  }
}
