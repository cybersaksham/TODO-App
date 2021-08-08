// Importing Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Importing External Packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importing dart Files
import './auth_form.dart';

// Importing Dart Models
import '../../Models/routes.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Booleans
  bool _isLoading = false;

  // Variables
  final _auth = FirebaseAuth.instance;

  // Function to show error snackbar
  void _showError(BuildContext ctx, String msg) {
    Scaffold.of(ctx).hideCurrentSnackBar();
    if (msg != null)
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
  }

  // Function to submit registration or login
  Future<void> _submitAuthForm(
    String name,
    String username,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) async {
    setState(() {
      _isLoading = true; // Showing loading spinner
    });

    // Making local variables
    AuthResult authResult;
    final email = '$username@app.com';

    try {
      if (isLogin) {
        // If user wants to login
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // If user wants to create new account
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Storing user data in database
        await Firestore.instance
            .collection('users')
            .document(authResult.user.uid)
            .collection('profile')
            .add({
          'name': name,
          'username': username,
        });
      }
      // Hiding last error if any
      _showError(ctx, null);
      // Routing to home page
      Navigator.of(context).pushReplacementNamed(Routes.home_screen);
    } on PlatformException catch (err) {
      // If some error occurred
      var msg = "An error occurred. Please check your credentials!";

      if (err.message != null) {
        msg = err.message;
        if (err.code == "ERROR_EMAIL_ALREADY_IN_USE") {
          msg = "This username is taken. Try another one.";
        } else if (err.code == "ERROR_USER_NOT_FOUND") {
          msg =
              "No user registered with this username. Click create new account for register.";
        }
      }

      // Showing error
      _showError(ctx, msg);
    } catch (err) {
      // Any other tyepe of error
      _showError(ctx, err);
    }

    setState(() {
      _isLoading = false; // Hiding loading spinner
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          margin: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: AuthForm(_isLoading, _submitAuthForm),
            ),
          ),
        ),
      ),
    );
  }
}
