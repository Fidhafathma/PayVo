/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class PinEntryPage extends StatefulWidget {
  @override
  _PinEntryPageState createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  final TextEditingController _pinController = TextEditingController();

  Future<void> _verifyPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPin = prefs.getString('user_pin');

    if (_pinController.text == storedPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PIN Verified!"),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Incorrect PIN! Try Again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _savePin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String enteredPin = _pinController.text;

    if (enteredPin.length == 4) {
      await prefs.setString('user_pin', enteredPin);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Your PIN is set: $enteredPin"),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PIN must be exactly 4 digits!"),
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
          children: [
            Text(
              "Enter Your PIN Here",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: "PIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _savePin,
                  child: const Text("Save PIN"),
                ),
                ElevatedButton(
                  onPressed: _verifyPin,
                  child: const Text("Verify"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class PinEntryPage extends StatefulWidget {
  @override
  _PinEntryPageState createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  String pin = '';
  String storedPin = '';

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storedPin = prefs.getString('user_pin') ?? '';
    });
  }

  void _handleKeyPress(String value) async {
    if (pin.length < 4) {
      setState(() {
        pin += value;
      });
      if (pin.length == 4) {
        await _verifyPin();
      }
    }
  }

  void _deletePin() {
    if (pin.isNotEmpty) {
      setState(() {
        pin = pin.substring(0, pin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    if (pin == storedPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PIN Verified!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect PIN! Try Again."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        pin = '';
      });
    }
  }

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: pin.length > index ? Colors.black : Colors.grey,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            pin.length > index ? pin[index] : '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String value, String letters) {
    return GestureDetector(
      onTap: () => _handleKeyPress(value),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              letters,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _deletePin,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: const Icon(
          Icons.backspace_outlined,
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: [
        _buildNumberButton('1',''),
        _buildNumberButton('2', ''),
        _buildNumberButton('3', ''),
        _buildNumberButton('4', ''),
        _buildNumberButton('5', ''),
        _buildNumberButton('6', ''),
        _buildNumberButton('7', ''),
        _buildNumberButton('8', ''),
        _buildNumberButton('9', ''),
        const SizedBox(),
        //_buildNumberButton('submit', ''),
        _buildNumberButton('0', ''),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return GestureDetector(
      onTap: pin.length == 4 ? _verifyPin : null,
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: pin.length == 4 ? Colors.blue : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Text(
          "Verify now",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000957),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your 4-digit PIN",
              style: TextStyle(
                color: Color.fromARGB(255, 246, 246, 248),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 14),
            _buildPinDisplay(),
            const SizedBox(height: 28),
            _buildKeypad(),
            const SizedBox(height: 24),
            //_buildVerifyButton(),
          ],
        ),
      ),
    );
  }
}