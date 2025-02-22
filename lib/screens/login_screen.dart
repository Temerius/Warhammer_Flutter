import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Please fill in all fields')));
      return;
    }

    if (!EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Please enter a valid email')));
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      String errorMessage;

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'User not found. Please check your email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          default:
            errorMessage = 'Failed to sign in. Please try again.';
        }
      } else {
        errorMessage = 'An error occurred. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'displayName': user.displayName ?? 'New User',
            'birthDate': DateTime(2000, 1, 1),
            'favoriteUniverse': 'none',
            'mainFaction': 'none',
            'experienceLevel': 'Beginner',
            'paintingSkill': 'Beginner',
            'bio': 'No bio',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'favorites': [],
            'favoriteSetsCount': 0,
            'totalSetsValue': 0.0,
            'miniatureBuildingSkills': 'Beginner',
            'tournamentExperience': 0,
          });
        }
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google login failed: ${e.toString()}')));
    }
  }

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Please enter your email')));
      return;
    }

    if (!EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Please enter a valid email')));
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Password reset link sent to your email')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Failed to send password reset link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginWithGoogle,
                child: const Text('Sign In with Google'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}