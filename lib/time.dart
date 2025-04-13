/*import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class TimeSelectionPage extends StatefulWidget {
  const TimeSelectionPage({Key? key}) : super(key: key);

  @override
  _TimeSelectionPageState createState() => _TimeSelectionPageState();
}

class _TimeSelectionPageState extends State<TimeSelectionPage> {
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  Future<void> _loadSavedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? hour = prefs.getInt('selected_hour');
    int? minute = prefs.getInt('selected_minute');
    if (hour != null && minute != null) {
      setState(() {
        selectedTime = TimeOfDay(hour: hour, minute: minute);
      });
    }
  }

  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: false, // Ensures 12-hour format with AM/PM
                  initialDateTime: DateTime(2024, 1, 1, selectedTime?.hour ?? 9,
                      selectedTime?.minute ?? 0),
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      selectedTime =
                          TimeOfDay(hour: newTime.hour, minute: newTime.minute);
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text("Done",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveTimeAndProceed() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select a time for SMS parsing!"),
            backgroundColor: Colors.red),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_hour', selectedTime!.hour);
    await prefs.setInt('selected_minute', selectedTime!.minute);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Time Saved Successfully!"),
          backgroundColor: Colors.green),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Set Your Time",
                  style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000957))),
              const SizedBox(height: 8),
              Text("Pick a time of the day when you like to get the SMS parsed",
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.poppins(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _showTimePicker,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000957),
                    foregroundColor: Colors.white),
                child: Text(
                    selectedTime == null
                        ? "Pick a Time"
                        : "Selected Time: ${selectedTime!.format(context)}",
                    style: GoogleFonts.poppins(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTimeAndProceed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000957),
                    foregroundColor: Colors.white),
                child: Text("Save & Continue",
                    style: GoogleFonts.poppins(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfirstapp/work_manager.dart'; // Import WorkManager file
import 'dashboard.dart';

class TimeSelectionPage extends StatefulWidget {
  const TimeSelectionPage({Key? key}) : super(key: key);

  @override
  _TimeSelectionPageState createState() => _TimeSelectionPageState();
}

class _TimeSelectionPageState extends State<TimeSelectionPage> {
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  Future<void> _loadSavedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? hour = prefs.getInt('selected_hour');
    int? minute = prefs.getInt('selected_minute');

    if (hour != null && minute != null) {
      setState(() {
        selectedTime = TimeOfDay(hour: hour, minute: minute);
      });
    }
  }

  void _showTimePicker() {
    DateTime initialDateTime = DateTime(2024, 1, 1, selectedTime.hour, selectedTime.minute);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: false,
                  initialDateTime: initialDateTime,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      selectedTime = TimeOfDay(hour: newTime.hour, minute: newTime.minute);
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text("Done",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveTimeAndProceed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_hour', selectedTime.hour);
    await prefs.setInt('selected_minute', selectedTime.minute);

    // 🔄 Reschedule WorkManager with new time

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Time set to ${selectedTime.format(context)}. SMS Parsing Rescheduled!",
            style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Set Your Time",
                  style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF000957))),
              const SizedBox(height: 8),
              Text("Pick a time of the day when you like to get the SMS parsed",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _showTimePicker,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000957), foregroundColor: Colors.white),
                child: Text(
                    "Selected Time: ${selectedTime.format(context)}",
                    style: GoogleFonts.poppins(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTimeAndProceed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000957), foregroundColor: Colors.white),
                child: Text("Save & Continue", style: GoogleFonts.poppins(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
