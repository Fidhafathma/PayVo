import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
 // Import DashboardPage

class SetPinPage extends StatefulWidget {
  @override
  _SetPinPageState createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  Future<void> _savePin() async {
    if (_pinController.text.length != 4 ||
        _confirmPinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("PIN must be 4 digits!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("PINs do not match!"), backgroundColor: Colors.red),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', _pinController.text); // Store PIN locally

    // Show PIN set notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Your PIN is set"),
        backgroundColor: Colors.green,
      ),
    );

    // Delay navigation to allow user to see notification
    await Future.delayed(Duration(seconds: 2));

    // Navigate to Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000957),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Set Your PIN",
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 255, 255))),
            const SizedBox(height: 20),
            /*TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
               obscuringCharacter: '●',
              obscureText: true,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: "Enter PIN",
                labelStyle:TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderSide:BorderSide(color:Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: "Confirm PIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePin,
              
              child: Text("Save PIN",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),*/
            TextField(
  controller: _pinController,
  keyboardType: TextInputType.number,
  obscureText: true,
  obscuringCharacter: '●', // White dot for entered PIN
  maxLength: 4,
  style: TextStyle(color: Colors.white), // PIN color white
  decoration: InputDecoration(
    labelText: "Enter PIN",
    labelStyle: TextStyle(color: Colors.white), // Label color
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white), // White border
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white), // White border
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2), // Highlighted border
    ),
  ),
),
const SizedBox(height: 10),
TextField(
  controller: _confirmPinController,
  keyboardType: TextInputType.number,
  obscureText: true,
  obscuringCharacter: '●', // White dot for entered PIN
  maxLength: 4,
  style: TextStyle(color: Colors.white), // PIN color white
  decoration: InputDecoration(
    labelText: "Confirm PIN",
    labelStyle: TextStyle(color: Colors.white), // Label color
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white), // White border
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white), // White border
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2), // Highlighted border
    ),
  ),
),
ElevatedButton(
              onPressed: _savePin,
              
              child: Text("Save PIN",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),

          ],
        ),
      ),
    );
  }
}