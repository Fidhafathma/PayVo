/*import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfirstapp/sms_parser.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class BackgroundTaskManager {
  /// **Initialize WorkManager (Call in main.dart)**
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  /// **Schedule SMS Parsing Task at User-defined Time**
  static Future<void> scheduleSMSParsing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? hour = prefs.getInt('selected_hour');
    int? minute = prefs.getInt('selected_minute');

    if (hour == null || minute == null) {
      hour = 9;
      minute = 0;
    }

    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    Duration initialDelay = scheduledTime.difference(now);
  print("📅 Scheduling SMS Parsing Task...");
    await Workmanager().cancelAll(); // Cancel previous tasks

    await Workmanager().registerPeriodicTask(
      "smsParsingTask",
      "fetchAndStoreTransactions",
      frequency: const Duration(hours: 24), 
      initialDelay: initialDelay, 
      constraints: Constraints(
        networkType: NetworkType.connected, // Ensures internet availability
      ),
      backoffPolicy: BackoffPolicy.linear, // Retry mechanism
    );

    print("✅ SMS Parsing scheduled at $hour:$minute");
  }
}

/// **Background Task Callback Function**
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(); // ✅ Ensure Firebase is initialized

    print("🔄 Running SMS parsing in background...");
    await SMSParser().fetchAndStoreTransactions();
    print("✅ SMS parsing task completed.");

    return Future.value(true);
  });
}*/



import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myfirstapp/sms_parser.dart';

class BackgroundTaskManager {
  /// **Initialize WorkManager (Call in main.dart)**
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  /// **Schedule SMS Parsing Task at User-defined Time**
  static Future<void> scheduleSMSParsing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? hour = prefs.getInt('selected_hour');
    int? minute = prefs.getInt('selected_minute');

    if (hour == null || minute == null) {
      hour = 9;
      minute = 0;
    }

    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // If the selected time is before the current time, schedule it for the next day
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    Duration initialDelay = scheduledTime.difference(now);

    print("📅 Scheduling SMS Parsing Task at $hour:$minute (Delay: ${initialDelay.inSeconds} seconds)");

    await Workmanager().cancelAll(); // Cancel previous tasks

    await Workmanager().registerOneOffTask(
      "smsParsingTask",
      "fetchAndStoreTransactions",
      initialDelay: initialDelay, // Waits until user-defined time
      constraints: Constraints(
        networkType: NetworkType.connected, // Ensures internet availability
      ),
      backoffPolicy: BackoffPolicy.linear, // Retry mechanism
    );

    print("✅ SMS Parsing scheduled at $hour:$minute");
  }
}

/// **Background Task Callback Function**
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    print("🔄 Running SMS parsing in background...");
    
    print("✅ SMS parsing task completed.");

    // Reschedule the task after execution to run again the next day
    await BackgroundTaskManager.scheduleSMSParsing();

    return Future.value(true);
  });
}

