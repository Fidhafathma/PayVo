import 'package:flutter/material.dart';
//import 'package:mtc/prayerindex/prayergroups.dart';
import 'forgotpassword.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 121, 12, 121),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color.fromARGB(255, 200, 110, 210),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Welcome Text
                const Text(
                  "Welcome AYSHA^2,FIDHA!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 76, 4, 83),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Log in to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),

                // Username TextField
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person,
                        color: Color.fromARGB(255, 190, 24, 168)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 125, 15, 125)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password TextField
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock,
                        color: Color.fromARGB(255, 218, 68, 255)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 202, 68, 255)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 246, 246, 247),
                    foregroundColor: const Color.fromARGB(255, 170, 68, 207),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus
                        ?.unfocus(); // 👈 Unfocus text fields before navigating
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage()),
                    );
                  },
                  child: Text('Forgot Password?'),
                ),
                const SizedBox(height: 20),

                // Forgot Password Text
                GestureDetector(
                  onTap: () {
                    // Handle Forgot Password
                  },
                  child: const Text(
                    "Forgot your password?",
                    style: TextStyle(
                      color: Color.fromARGB(255, 142, 48, 213),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
