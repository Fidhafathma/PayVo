import 'package:flutter/material.dart';
import 'dashboard.dart'; // Import the DashboardPage

class LoginPage2 extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage2> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus
          ?.unfocus(), // Dismiss keyboard when tapping outside
      child: Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                autofocus: false,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                autofocus: false,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Simulate login success and navigate to the dashboard page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardPage()),
                  );
                },
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus
                      ?.unfocus(); // Unfocus text fields before navigating
                  // Navigate to ForgotPasswordPage (implement this page accordingly)
                },
                child: Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
