import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _resetPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email.")),
      );
      return;
    }

    try {
      // Check if the email is registered
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(email);

      if (signInMethods.isNotEmpty) {
        // Email is registered, send password reset email
        await _auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset link sent! Check your email."),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context); // Closes the ForgotPasswordPage
        });
      } else {
        // Email is not registered
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No account found for that email."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Enter your email to reset your password",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: GoogleFonts.poppins(),
                prefixIcon: const Icon(Icons.email, color: Color(0xFF000957)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF000957)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000957),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Reset Password',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}