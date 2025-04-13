import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfirstapp/add_transaction.dart';
import 'package:myfirstapp/analysis.dart';
import 'package:myfirstapp/sms_parser.dart'; // ✅ Import SMS Parser
import 'package:month_picker_dialog/month_picker_dialog.dart'; // ✅ Import Month Picker

import 'package:myfirstapp/main.dart';
import 'package:myfirstapp/unrecognizedcategory.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime selectedDate = DateTime.now();
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  /// *📅 Open Month-Year Picker*
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
      _fetchTransactions();
    }
  }

  Future<void> _fetchTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String selectedMonth = DateFormat('yyyy-MM').format(selectedDate);

    double income = 0.0;
    double expense = 0.0;
    List<Map<String, dynamic>> fetchedTransactions = [];

    try {
      // Fetch from 'transactions' subcollection
      QuerySnapshot transactionsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: "$selectedMonth-01")
          .where('date', isLessThan: "$selectedMonth-32")
          .get();

      for (var doc in transactionsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String type = data['type'] ?? '';
        double amount = data['amount']?.toDouble() ?? 0.0;

        if (type == 'credit' || type == 'Income') {
          income += amount;
        } else if (type == 'debit' || type == 'Expense') {
          expense += amount;
        }

        fetchedTransactions.add(data);
      }

      // Fetch from 'manual_entry' subcollection
      QuerySnapshot manualEntrySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('manual_entry')
          .where('date', isGreaterThanOrEqualTo: "$selectedMonth-01")
          .where('date', isLessThan: "$selectedMonth-32")
          .get();

      for (var doc in manualEntrySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String type = data['type'] ?? '';
        double amount = data['amount']?.toDouble() ?? 0.0;

        if (type == 'Income' || type == 'credit') {
          income += amount;
        } else if (type == 'Expense' || type == 'debit') {
          expense += amount;
        }

        fetchedTransactions.add(data);
      }

      setState(() {
        totalIncome = double.parse(income.toStringAsFixed(2));
        totalExpense = double.parse(expense.toStringAsFixed(2));
        transactions = fetchedTransactions;
      });
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  Future<void> _fetchAndStoreTransactions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fetching SMS transactions...")),
    );

    try {
      await SMSParser().fetchAndStoreTransactions(user.uid);
      _fetchTransactions(); // ✅ Refresh transactions after fetching SMS
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transactions stored successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching transactions: $e")),
      );
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => WelcomePage()));
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  /*void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop(); // Closes app on Android
    } else if (Platform.isIOS) {
      exit(0); // Works for iOS (but Apple discourages this)
    }
  }*/

  @override
  Widget build(BuildContext context) {
    String currentMonthYear = DateFormat('MMMM yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.black), // ✅ Fetch Button
            onPressed: _fetchAndStoreTransactions,
          ),
          IconButton(
            icon:
                const Icon(Icons.exit_to_app_rounded, color: Color(0xFF000957)),
            onPressed: () => _showExitConfirmation(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF000957),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickMonthYear(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '〈 $currentMonthYear 〉',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_drop_down,
                              color: Colors.white, size: 28),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Income: Rs ${totalIncome.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                                color: Colors.green, fontSize: 13)),
                        Text('Expense: Rs ${totalExpense.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                                color: Colors.red, fontSize: 13)),
                      ],
                    ),
                  ],
                )),

            /// **📌 Display Total Income & Expense*
           /* Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF000957),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Total Income",
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white70),
                  ),
                  Text(
                    "₹$totalIncome",
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Total Expense",
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white70),
                  ),
                  Text(
                    "₹$totalExpense",
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),*/
            const SizedBox(height: 20),
            

            // *📌 Display Transactions*
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  var transaction = transactions[index];
                  bool isExpense = (transaction['type'] == 'Expense' ||
                      transaction['type'] == 'debit');

                  return ListTile(
                    leading: Icon(
                      isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                    title: Text(
                      transaction['category'] ?? 'Unknown',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      transaction['date'] ?? '',
                      style:
                          GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: Text(
                      'Rs ${(transaction['amount'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: const Color(0xFF000957),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(
              Icons.warning, // Unrecognized category icon
              color: Colors.white, // Change color to blue
              size: 35,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TransactionPage()));
            },
          ),
          Container(
            height: 55,
            width: 55,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF000957), size: 35),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddTransactionPage()));
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart, color: Colors.white, size: 35),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()));
            },
          ),
        ],
      ),
    );
  }
}