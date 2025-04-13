import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:myfirstapp/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  String _enteredPin = '';
  final String correctPin = '1234';

  @override
  void initState() {
    super.initState();
    _authenticateWithBiometrics();
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Monexo',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (isAuthenticated) {
        _navigateToHome();
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric auth error: $e');
    }
  }

  void _onDigitPressed(String digit) {
    setState(() {
      if (_enteredPin.length < 4) {
        _enteredPin += digit;
      }
      if (_enteredPin.length == 4) {
        if (_enteredPin == correctPin) {
          _navigateToHome();
        } else {
          _enteredPin = '';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect PIN, try again!')),
          );
        }
      }
    });
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.white),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter The Pin',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF000957),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length
                          ? const Color(0xFF000957)
                          : const Color(0xFFD1D1D1),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.3,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  String buttonText;
                  if (index < 9) {
                    buttonText = '${index + 1}';
                  } else if (index == 9) {
                    buttonText = '←';
                  } else if (index == 10) {
                    buttonText = '0';
                  } else {
                    buttonText = '✔';
                  }
                  return GestureDetector(
                    onTap: () {
                      if (buttonText == '←') {
                        setState(() {
                          if (_enteredPin.isNotEmpty) {
                            _enteredPin = _enteredPin.substring(
                                0, _enteredPin.length - 1);
                          }
                        });
                      } else if (buttonText == '✔') {
                        if (_enteredPin.length == 4) {
                          if (_enteredPin == correctPin) {
                            _navigateToHome();
                          } else {
                            setState(() {
                              _enteredPin = '';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Incorrect PIN, try again!')),
                            );
                          }
                        }
                      } else {
                        _onDigitPressed(buttonText);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF000957),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        buttonText,
                        style: GoogleFonts.poppins(
                          fontSize: buttonText == '←' ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _authenticateWithBiometrics,
                child: const Icon(Icons.fingerprint,
                    size: 50, color: Color(0xFF000957)),
              ),
              const SizedBox(height: 10),
              Text(
                'Use Fingerprint',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF000957),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
