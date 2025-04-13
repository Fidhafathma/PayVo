/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isIncome = false;
  bool isExpense = true;
  String selectedCategory = 'Shopping';
  String amount = '';
  DateTime? selectedDate;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Food', 'icon': Icons.fastfood},
    {'name': 'Electricity', 'icon': Icons.electrical_services},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (amount.isEmpty || amount == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Amount cannot be zero!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No user is logged in!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Save the transaction to the user's manual_entry collection
      await FirebaseFirestore.instance
          .collection('users') // Users collection
          .doc(user.uid) // Document for the specific user (user's UID)
          .collection('manual_entry') // Subcollection for manual entries
          .add({
        'date': selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'category': selectedCategory,
        'type': isIncome ? 'Income' : 'Expense',
        'amount': double.parse(amount),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transaction stored successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving transaction: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Transaction",
          style: TextStyle(
            color: Color(0xFF000957),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000957)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text(
              "Save",
              style: TextStyle(
                color: Color(0xFF000957),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Income/Expense Selection
            Row(
              children: [
                const SizedBox(width: 20),
                Radio(
                  value: true,
                  groupValue: isIncome,
                  onChanged: (value) {
                    setState(() {
                      isIncome = true;
                      isExpense = false;
                    });
                  },
                ),
                const Text("Income", style: TextStyle(fontSize: 18)),
                const SizedBox(width: 50),
                Radio(
                  value: true,
                  groupValue: isExpense,
                  onChanged: (value) {
                    setState(() {
                      isIncome = false;
                      isExpense = true;
                    });
                  },
                ),
                const Text("Expense", style: TextStyle(fontSize: 18)),
              ],
            ),

            const SizedBox(height: 20),

            // Select Category
            const Text(
              "Select Category:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000957)),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category['name'];
                    });
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width / 2) - 40,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedCategory == category['name']
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          category['icon'],
                          size: 30,
                          color: selectedCategory == category['name']
                              ? Color(0xFF000957)
                              : Colors.black,
                        ),
                        const SizedBox(height: 5),
                        Text(category['name'],
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Select Date
            Row(
              children: [
                const Text(
                  "Select Date:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000957)),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Row(
                    children: [
                      Text(
                        selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                            : "Choose a date",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today, color: Color(0xFF000957))
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Amount Display
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AmountInputDialog(
                    onAmountChanged: (value) {
                      setState(() {
                        amount = value;
                      });
                    },
                  ),
                );
              },
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Color(0xFF000957),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    amount.isEmpty ? "0" : amount,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Amount Input Dialog
class AmountInputDialog extends StatelessWidget {
  final Function(String) onAmountChanged;

  const AmountInputDialog({super.key, required this.onAmountChanged});

  @override
  Widget build(BuildContext context) {
    String inputAmount = '';
    return AlertDialog(
      title: const Text("Enter Amount"),
      content: TextField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          inputAmount = value;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            onAmountChanged(inputAmount);
            Navigator.pop(context);
          },
          child: const Text("✔"),
        ),
      ],
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isIncome = false;
  bool isExpense = true;
  String selectedCategory = 'Shopping';
  String amount = '';
  DateTime? selectedDate;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.fastfood},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Utilities', 'icon': Icons.electrical_services},
    {'name': 'Transportation', 'icon': Icons.directions_bus},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (amount.isEmpty || amount == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Amount cannot be zero!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No user is logged in!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Save the transaction to the user's manual_entry collection
      await FirebaseFirestore.instance
          .collection('users') // Users collection
          .doc(user.uid) // Document for the specific user (user's UID)
          .collection('manual_entry') // Subcollection for manual entries
          .add({
        'date': selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'category': selectedCategory,
        'type': isIncome ? 'Income' : 'Expense',
        'amount': double.parse(amount),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transaction stored successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving transaction: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Transaction",
          style: TextStyle(
            color: Color(0xFF000957),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000957)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text(
              "Save",
              style: TextStyle(
                color: Color(0xFF000957),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Income/Expense Selection
            Row(
              children: [
                const SizedBox(width: 20),
                Radio(
                  value: true,
                  groupValue: isIncome,
                  onChanged: (value) {
                    setState(() {
                      isIncome = true;
                      isExpense = false;
                    });
                  },
                ),
                const Text("Income", style: TextStyle(fontSize: 18)),
                const SizedBox(width: 50),
                Radio(
                  value: true,
                  groupValue: isExpense,
                  onChanged: (value) {
                    setState(() {
                      isIncome = false;
                      isExpense = true;
                    });
                  },
                ),
                const Text("Expense", style: TextStyle(fontSize: 18)),
              ],
            ),

            const SizedBox(height: 20),

            // Select Category
            const Text(
              "Select Category:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000957)),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category['name'];
                    });
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width / 2) - 40,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedCategory == category['name']
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          category['icon'],
                          size: 30,
                          color: selectedCategory == category['name']
                              ? Color(0xFF000957)
                              : Colors.black,
                        ),
                        const SizedBox(height: 5),
                        Text(category['name'],
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Select Date
            Row(
              children: [
                const Text(
                  "Select Date:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000957)),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Row(
                    children: [
                      Text(
                        selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                            : "Choose a date",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today, color: Color(0xFF000957))
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Amount Display
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AmountInputDialog(
                    onAmountChanged: (value) {
                      setState(() {
                        amount = value;
                      });
                    },
                  ),
                );
              },
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Color(0xFF000957),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    amount.isEmpty ? "0" : amount,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Amount Input Dialog
class AmountInputDialog extends StatelessWidget {
  final Function(String) onAmountChanged;

  const AmountInputDialog({super.key, required this.onAmountChanged});

  @override
  Widget build(BuildContext context) {
    String inputAmount = '';
    return AlertDialog(
      title: const Text("Enter Amount"),
      content: TextField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          inputAmount = value;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            onAmountChanged(inputAmount);
            Navigator.pop(context);
          },
          child: const Text("✔"),
        ),
      ],
    );
  }
}