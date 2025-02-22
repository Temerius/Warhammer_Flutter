import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _register() async {
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

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Password must be at least 6 characters')));
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'displayName': 'New User',
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

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      String errorMessage;

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email address is already registered.';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak. Please choose a stronger one.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          default:
            errorMessage = 'Failed to complete registration. Please try again.';
        }
      } else {
        errorMessage = 'An error occurred. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/registration.jpg'),
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
                onPressed: _register,
                child: const Text('Complete Registration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}