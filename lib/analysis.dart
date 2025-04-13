/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, double> dataMap = {};
  User? currentUser;

  final List<Color> colorList = [
    const Color.fromARGB(255, 11, 40, 173),
    const Color.fromARGB(255, 27, 91, 143),
    Colors.blue.shade400,
    const Color.fromARGB(255, 42, 122, 187),
    Colors.blue.shade600,
    const Color.fromARGB(255, 5, 76, 147),
    const Color.fromARGB(255, 35, 59, 86),
    const Color.fromARGB(255, 3, 25, 58),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Get the logged-in user
  void _getCurrentUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUser = user;
        });
        fetchDataFromFirestore(user.uid);
      }
    });
  }

  Future<void> fetchDataFromFirestore(String userId) async {
    Map<String, double> categoryTotals = {};

    // Fetch data from transactions
    await _fetchDataFromCollection(userId, 'transactions', categoryTotals);

    // Fetch data from manual_entry
    await _fetchDataFromCollection(userId, 'manual_entry', categoryTotals);

    setState(() {
      dataMap = categoryTotals;
    });
  }

  // Helper function to fetch data from a specific collection
  Future<void> _fetchDataFromCollection(String userId, String collectionName,
      Map<String, double> categoryTotals) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collectionName);

    QuerySnapshot snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      String category = doc['category'];
      double amount = doc['amount'].toDouble();

      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + amount;
      } else {
        categoryTotals[category] = amount;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Expense Distribution"),
        toolbarHeight: 50, // Decreased app bar height
      ),
      body: Center(
        child: currentUser == null
            ? const Text("Please log in to see data")
            : dataMap.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "View Your Monthly Analysis Here",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      PieChart(
                        dataMap: dataMap,
                        chartType: ChartType.ring, // Donut chart
                        ringStrokeWidth: 32,
                        chartRadius: MediaQuery.of(context).size.width / 2,
                        colorList: colorList,
                        legendOptions: const LegendOptions(
                          showLegends: true,
                          legendPosition: LegendPosition.bottom,
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValuesInPercentage: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          children: dataMap.entries.map((entry) {
                            return ListTile(
                              title: Text(entry.key),
                              trailing:
                                  Text("₹${entry.value.toStringAsFixed(2)}"),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}*/
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, double> dataMap = {};
  User? currentUser;
  DateTime selectedDate = DateTime.now();

  final List<Color> colorList = [
    const Color.fromARGB(255, 11, 40, 173),
    const Color.fromARGB(255, 27, 91, 143),
    Colors.blue.shade400,
    const Color.fromARGB(255, 42, 122, 187),
    Colors.blue.shade600,
    const Color.fromARGB(255, 5, 76, 147),
    const Color.fromARGB(255, 35, 59, 86),
    const Color.fromARGB(255, 3, 25, 58),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Get the logged-in user
  void _getCurrentUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUser = user;
        });
        fetchDataFromFirestore(user.uid);
      }
    });
  }

  // Pick month and year
  Future<void> _pickMonthAndYear(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate:
          DateTime(now.year, now.month + 1, 0), // Last day of current month
      initialDatePickerMode: DatePickerMode.year,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
      if (currentUser != null) {
        fetchDataFromFirestore(currentUser!.uid);
      }
    }
  }

  // Fetch data from Firestore for selected month and year
  /* Future<void> fetchDataFromFirestore(String userId) async {
    Map<String, double> categoryTotals = {};

    // Fetch from transactions
    await _fetchDataFromCollection(userId, 'transactions', categoryTotals);

    // Fetch from manual_entry
    await _fetchDataFromCollection(userId, 'manual_entry', categoryTotals);

    setState(() {
      dataMap = categoryTotals;
    });
  }*/

  // Fetch data from Firestore and filter by selected month and year
  /*Future<void> _fetchDataFromCollection(String userId, String collectionName,
      Map<String, double> categoryTotals) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collectionName);

    QuerySnapshot snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      try {
        String dateString = doc['date']; // Date stored as String
        DateTime date = DateTime.parse(dateString); // Convert to DateTime

        // Filter based on selected month and year
        if (date.year == selectedDate.year && date.month == selectedDate.month) {
          String category = doc['category'];
          double amount = doc['amount'].toDouble();

          if (categoryTotals.containsKey(category)) {
            categoryTotals[category] = categoryTotals[category]! + amount;
          } else {
            categoryTotals[category] = amount;
          }
        }
      } catch (e) {
        print("Error parsing date: $e");
      }
    }
  }*/
  /* Future<void> fetchDataFromFirestore(String userId) async {
    Map<String, double> categoryTotals = {};

    // Handle transactions collection (date stored as String or Timestamp)
    await _fetchDataFromCollection(userId, 'transactions', categoryTotals,
        isManualEntry: false);

    // Handle manual_entry collection (date stored as Timestamp or String)
    await _fetchDataFromCollection(userId, 'manual_entry', categoryTotals,
        isManualEntry: true);

    setState(() {
      dataMap = categoryTotals;
    });
  }

  Future<void> _fetchDataFromCollection(
      String userId, String collectionName, Map<String, double> categoryTotals,
      {required bool isManualEntry}) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collectionName);

    QuerySnapshot snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      try {
        DateTime? date;

        if (isManualEntry) {
          // Use timestamp if it exists, else fallback to date
          if (doc.data().toString().contains('timestamp')) {
            date = (doc['timestamp'] as Timestamp).toDate();
          } else if (doc.data().toString().contains('date')) {
            date = DateTime.parse(doc['date']);
          }
        } else {
          // Check if date is a String or Timestamp
          if (doc['date'] is Timestamp) {
            date = (doc['date'] as Timestamp).toDate();
          } else if (doc['date'] is String) {
            date = DateTime.parse(doc['date']);
          }
        }

        if (date != null &&
            date.year == selectedDate.year &&
            date.month == selectedDate.month) {
          String category = doc['category'];
          double amount = doc['amount'].toDouble();

          if (categoryTotals.containsKey(category)) {
            categoryTotals[category] = categoryTotals[category]! + amount;
          } else {
            categoryTotals[category] = amount;
          }
        }
      } catch (e) {
        print("Error parsing date in $collectionName: $e");
      }
    }
  }
*/
  Future<void> fetchDataFromFirestore(String userId) async {
    Map<String, double> categoryTotals = {};

    // Handle transactions collection
    await _fetchDataFromCollection(userId, 'transactions', categoryTotals,
        isManualEntry: false);

    // Handle manual_entry collection
    await _fetchDataFromCollection(userId, 'manual_entry', categoryTotals,
        isManualEntry: true);

    setState(() {
      dataMap = categoryTotals;
    });
  }

  Future<void> _fetchDataFromCollection(
      String userId, String collectionName, Map<String, double> categoryTotals,
      {required bool isManualEntry}) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collectionName);

    QuerySnapshot snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      try {
        DateTime? date;

        if (doc['date'] is Timestamp) {
          // If it's a Timestamp, convert to DateTime
          date = (doc['date'] as Timestamp).toDate();
        } else if (doc['date'] is String) {
          // If it's a String, parse it to DateTime
          date = DateTime.parse(doc['date']);
        }

        if (date != null &&
            date.year == selectedDate.year &&
            date.month == selectedDate.month) {
          String category = doc['category'];
          double amount = doc['amount'].toDouble();

          if (categoryTotals.containsKey(category)) {
            categoryTotals[category] = categoryTotals[category]! + amount;
          } else {
            categoryTotals[category] = amount;
          }
        }
      } catch (e) {
        print("Error parsing date in $collectionName: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentMonthYear =
        DateFormat('MMMM yyyy').format(selectedDate); // Format month & year

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Expense Distribution"),
        toolbarHeight: 50,
      ),
      body: Center(
        child: currentUser == null
            ? const Text("Please log in to see data")
            : dataMap.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _pickMonthAndYear(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentMonthYear,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      PieChart(
                        dataMap: dataMap,
                        chartType: ChartType.ring,
                        ringStrokeWidth: 32,
                        chartRadius: MediaQuery.of(context).size.width / 2,
                        colorList: colorList,
                        legendOptions: const LegendOptions(
                          showLegends: true,
                          legendPosition: LegendPosition.bottom,
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValuesInPercentage: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          children: dataMap.entries.map((entry) {
                            return ListTile(
                              title: Text(entry.key),
                              trailing:
                                  Text("₹${entry.value.toStringAsFixed(2)}"),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, double> dataMap = {};
  User? currentUser;
  DateTime selectedDate = DateTime.now();

  final List<Color> colorList = [
  Color(0xFFFAA61A), // Orange (Market A)
  Color(0xFFFECF66), // Light Orange (Product B)
  Color(0xFFFFE9B3), // Pale Yellow (Product C)

  Color(0xFF007AC3), // Blue (Market B)
  Color(0xFF1B5B8F), // Medium Blue (Product D)
  Color(0xFF2A7ABB), // Light Blue (Product E)

  Color(0xFF6B4F9B), // Purple (Market C)
  Color(0xFFD7A1D3), // Light Purple (Product F)
  Color(0xFFE2C5E8), // Pale Pinkish Purple (Product G)
];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Get the logged-in user
  void _getCurrentUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUser = user;
        });
        fetchDataFromFirestore(user.uid);
      }
    });
  }

  // Pick month and year
 /* Future<void> _pickMonthAndYear(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate:
          DateTime(now.year, now.month + 1, 0), // Last day of current month
      initialDatePickerMode: DatePickerMode.year,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
      if (currentUser != null) {
        fetchDataFromFirestore(currentUser!.uid);
      }
    }
  }
*/
Future<void> _pickMonthYear(BuildContext context) async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      if (currentUser != null) {
        fetchDataFromFirestore(currentUser!.uid);
      }
      
    }
  }
  // Fetch data from Firestore for selected month and year
  /* Future<void> fetchDataFromFirestore(String userId) async {
    Map<String, double> categoryTotals = {};

    // Fetch from transactions
    await _fetchDataFromCollection(userId, 'transactions', categoryTotals);

    // Fetch from manual_entry
    await _fetchDataFromCollection(userId, 'manual_entry', categoryTotals);

    setState(() {
      dataMap = categoryTotals;
    });
  }*/

  // Fetch data from Firestore and filter by selected month and year
  /*Future<void> _fetchDataFromCollection(String userId, String collectionName,
      Map<String, double> categoryTotals) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collectionName);

    QuerySnapshot snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      try {
        String dateString = doc['date']; // Date stored as String
        DateTime date = DateTime.parse(dateString); // Convert to DateTime

        // Filter based on selected month and year
        if (date.year == selectedDate.year && date.month == selectedDate.month) {
          String category = doc['category'];
          double amount = doc['amount'].toDouble();

          if (categoryTotals.containsKey(category)) {
            categoryTotals[category] = categoryTotals[category]! + amount;
          } else {
            categoryTotals[category] = amount;
          }
        }
      } catch (e) {
        print("Error parsing date: $e");
      }
    }
  }*/
  /* Future<void> fetchDataFromFirestore(String userId) async {
    Map<String, double> categoryTotals = {};

    // Handle transactions collection (date stored as String or Timestamp)
    await _fetchDataFromCollection(userId, 'transactions', categoryTotals,
        isManualEntry: false);

    // Handle manual_entry collection (date stored as Timestamp or String)
    await _fetchDataFromCollection(userId, 'manual_entry', categoryTotals,
        isManualEntry: true);

    setState(() {
      dataMap = categoryTotals;
    });
  }

  Future<void> _fetchDataFromCollection(
      String userId, String collectionName, Map<String, double> categoryTotals,
      {required bool isManualEntry}) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collectionName);

    QuerySnapshot snapshot = await collection.get();

    for (var doc in snapshot.docs) {
      try {
        DateTime? date;

        if (isManualEntry) {
          // Use timestamp if it exists, else fallback to date
          if (doc.data().toString().contains('timestamp')) {
            date = (doc['timestamp'] as Timestamp).toDate();
          } else if (doc.data().toString().contains('date')) {
            date = DateTime.parse(doc['date']);
          }
        } else {
          // Check if date is a String or Timestamp
          if (doc['date'] is Timestamp) {
            date = (doc['date'] as Timestamp).toDate();
          } else if (doc['date'] is String) {
            date = DateTime.parse(doc['date']);
          }
        }

        if (date != null &&
            date.year == selectedDate.year &&
            date.month == selectedDate.month) {
          String category = doc['category'];
          double amount = doc['amount'].toDouble();

          if (categoryTotals.containsKey(category)) {
            categoryTotals[category] = categoryTotals[category]! + amount;
          } else {
            categoryTotals[category] = amount;
          }
        }
      } catch (e) {
        print("Error parsing date in $collectionName: $e");
      }
    }
  }
*/
  Future<void> fetchDataFromFirestore(String userId) async {
    Map<String, double> categoryTotals = {};

    // Handle transactions collection
    await _fetchDataFromCollection(userId, 'transactions', categoryTotals,
        isManualEntry: false);

    // Handle manual_entry collection
    await _fetchDataFromCollection(userId, 'manual_entry', categoryTotals,
        isManualEntry: true);

    setState(() {
      dataMap = categoryTotals;
    });
  }

  /* Future<void> _fetchDataFromCollection(
      String userId, String collectionName, Map<String, double> categoryTotals,
      {required bool isManualEntry}) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collectionName);

    //QuerySnapshot snapshot = await collection.get();
    //QuerySnapshot snapshot =
    //  await collection.where('type', isEqualTo: 'expense').get();
    QuerySnapshot snapshot;

    if (collectionName == 'transactions') {
      // For transactions, check for type 'debit'
      snapshot = await collection.where('type', isEqualTo: 'debit').get();
    } else {
      // For manual_entry, check for type 'expense'
      snapshot = await collection.where('type', isEqualTo: 'expense').get();
    }

    print("Documents fetched from $collectionName: ${snapshot.docs.length}");

    for (var doc in snapshot.docs) {
      try {
        DateTime? date;

        if (doc['date'] is Timestamp) {
          // If it's a Timestamp, convert to DateTime
          date = (doc['date'] as Timestamp).toDate();
        } else if (doc['date'] is String) {
          // If it's a String, parse it to DateTime
          date = DateTime.parse(doc['date']);
        }

        if (date != null &&
            date.year == selectedDate.year &&
            date.month == selectedDate.month) {
          String category = doc['category'];
          double amount = doc['amount'].toDouble();

          if (categoryTotals.containsKey(category)) {
            categoryTotals[category] = categoryTotals[category]! + amount;
          } else {
            categoryTotals[category] = amount;
          }
        }
      } catch (e) {
        print("Error parsing date in $collectionName: $e");
      }
    }
  }*/
  ////Future<void> _fetchDataFromCollection(String userId, String collectionName,
  //Map<String, double> categoryTotals) async {
  Future<void> _fetchDataFromCollection(
      String userId, String collectionName, Map<String, double> categoryTotals,
      {required bool isManualEntry}) async {
    CollectionReference collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collectionName);

    try {
      QuerySnapshot snapshot;

      if (collectionName == 'transactions') {
        // For transactions, check type 'debit'
        snapshot = await collection.where('type', isEqualTo: 'debit').get();
      } else {
        // For manual_entry, check type 'Expense' (case-insensitive)
        snapshot = await collection.where('type', isEqualTo: 'Expense').get();
      }

      for (var doc in snapshot.docs) {
        try {
          DateTime? date;

          if (collectionName == 'manual_entry') {
            if (doc['timestamp'] != null) {
              date = (doc['timestamp'] as Timestamp).toDate();
            }
          } else {
            if (doc['date'] is Timestamp) {
              date = (doc['date'] as Timestamp).toDate();
            } else if (doc['date'] is String) {
              date = DateTime.parse(doc['date']);
            }
          }

          if (date != null &&
              date.year == selectedDate.year &&
              date.month == selectedDate.month) {
            String category = doc['category'];
            double amount = doc['amount'].toDouble();

            if (categoryTotals.containsKey(category)) {
              categoryTotals[category] = categoryTotals[category]! + amount;
            } else {
              categoryTotals[category] = amount;
            }
          }
        } catch (e) {
          print("Error parsing document in $collectionName: $e");
        }
      }
    } catch (e) {
      print("Firestore query error in $collectionName: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentMonthYear =
        DateFormat('MMMM yyyy').format(selectedDate); // Format month & year

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Expense Distribution"),
        toolbarHeight: 50,
      ),
      body: Center(
        child: currentUser == null
            ? const Text("Please log in to see data")
            : dataMap.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _pickMonthYear(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentMonthYear,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      PieChart(
                        dataMap: dataMap,
                        chartType: ChartType.ring,
                        ringStrokeWidth: 32,
                        chartRadius: MediaQuery.of(context).size.width / 2,
                        colorList: colorList,
                        legendOptions: const LegendOptions(
                          showLegends: true,
                          legendPosition: LegendPosition.bottom,
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValuesInPercentage: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          children: dataMap.entries.map((entry) {
                            return ListTile(
                              title: Text(entry.key),
                              trailing:
                                  Text("₹${entry.value.toStringAsFixed(2)}"),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}