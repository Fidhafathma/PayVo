import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myfirstapp/setpinpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _setFirstTimeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  Future<bool> _isEmailAlreadyInUse(String email) async {
    try {
      final signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Passwords do not match!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Invalid email format!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    final emailInUse = await _isEmailAlreadyInUse(_emailController.text.trim());
    if (emailInUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("This email is already in use! Please log in."),
            backgroundColor: Colors.red),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();
        setState(() {
          _isEmailSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verification email sent! Please check your inbox."),
            backgroundColor: Colors.green,
          ),
        );

        // Wait for user to verify email before proceeding
        await _waitForEmailVerification(user);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _waitForEmailVerification(User user) async {
    int attempts = 0;
    while (attempts < 12) {
      // Check every 5 sec for 1 min
      await Future.delayed(const Duration(seconds: 5));
      await user.reload();

      user = FirebaseAuth.instance.currentUser!;
      if (user.emailVerified) {
        // Store user in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'created_at': Timestamp.now(),
        });

        // Initialize user collections
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('manual_entry')
            .add({
          'date': Timestamp.now(),
          'amount': 0.0,
          'category': 'Sample',
          'type': 'expense',
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .add({
          'date': Timestamp.now(),
          'amount': 0.0,
          'transaction_id': 'sample_id',
          'category': 'Sample',
          'type': 'expense',
          'user_id': user.uid,
        });

        await _setFirstTimeStatus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Signup Successful! Redirecting to PIN setup..."),
              backgroundColor: Colors.green),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SetPinPage()),
          );
        }
        return;
      }
      attempts++;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Email not verified yet! Please check your inbox."),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Sign Up",
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000957)),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  "Create your account",
                  style:
                      GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.poppins(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF000957)),
                  border: const OutlineInputBorder(),
                ),
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: GoogleFonts.poppins(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF000957)),
                  border: const OutlineInputBorder(),
                ),
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  labelStyle: GoogleFonts.poppins(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF000957)),
                  border: const OutlineInputBorder(),
                ),
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000957),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Sign Up",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}