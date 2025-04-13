/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myfirstapp/dashboard.dart';
import 'package:myfirstapp/forgotpassword.dart';
import 'package:myfirstapp/setpinpage.dart';
//import 'package:myfirstapp/setpinpage.dart'; // Import SetPinPage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );

      // Navigate to SetPinPage first
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SetPinPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Login",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF000957),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Login to your account",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF000957),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                style: GoogleFonts.poppins(color: const Color(0xFF000957)),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF000957)),
                  labelText: "Email",
                  labelStyle:
                      GoogleFonts.poppins(color: const Color(0xFF000957)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.poppins(color: const Color(0xFF000957)),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF000957)),
                  labelText: "Password",
                  labelStyle:
                      GoogleFonts.poppins(color: const Color(0xFF000957)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000957),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordPage(),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF000957),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myfirstapp/dashboard.dart';
import 'package:myfirstapp/forgotpassword.dart';
import 'package:myfirstapp/setpinpage.dart';
import 'package:myfirstapp/setpinpage.dart'; // Import SetPinPage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );

      // Navigate to SetPinPage first
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SetPinPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Incorrect login credentials",
            style: TextStyle(
                color: Color.fromARGB(255, 219, 61, 61)), // Text color
          ),
          backgroundColor:
              const Color.fromARGB(255, 243, 240, 240), // Background color
        ),
      );
    }
  }

//${e.toString()}
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Login",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF000957),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Login to your account",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF000957),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                style: GoogleFonts.poppins(color: const Color(0xFF000957)),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF000957)),
                  labelText: "Email",
                  labelStyle:
                      GoogleFonts.poppins(color: const Color(0xFF000957)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.poppins(color: const Color(0xFF000957)),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF000957)),
                  labelText: "Password",
                  labelStyle:
                      GoogleFonts.poppins(color: const Color(0xFF000957)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000957),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordPage(),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF000957),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}