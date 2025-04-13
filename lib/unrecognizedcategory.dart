/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('category', isEqualTo: 'Uncategorized')
          .get();

      setState(() {
        transactions = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    }
  }

  /* Future<void> updateCategory(String transactionId, String newCategory) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          //.doc(transactionId)
          .where('transaction_id', isEqualTo: 'transactionId')
          .update({'category': newCategory});

      fetchTransactions(); // Refresh the list after update
    }
  }*/
  Future<void> updateCategory(String transactionId, String newCategory) async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('transaction_id', isEqualTo: transactionId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'category': newCategory});
      }

      fetchTransactions(); // Refresh list after update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                var transaction = transactions[index];
                return ListTile(
                  title: Text('Amount: ${transaction['amount']}'),
                  subtitle: Text('Date: ${transaction['date']}'),
                  trailing: DropdownButton<String>(
                    value: transaction['category'],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        updateCategory(transaction['transaction_id'], newValue);
                      }
                    },
                    items: <String>[
                      'Education',
                      'Entertainment',
                      'Food',
                      'Uncategorized'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}*/
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('category', isEqualTo: 'Uncategorized')
          .get();

      setState(() {
        transactions = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    }
  }

  /* Future<void> updateCategory(String transactionId, String newCategory) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          //.doc(transactionId)
          .where('transaction_id', isEqualTo: 'transactionId')
          .update({'category': newCategory});

      fetchTransactions(); // Refresh the list after update
    }
  }*/
  Future<void> updateCategory(String transactionId, String newCategory) async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('transaction_id', isEqualTo: transactionId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'category': newCategory});
      }

      fetchTransactions(); // Refresh list after update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                var transaction = transactions[index];
                return ListTile(
                  title: Text('Amount: ${transaction['amount']}'),
                  subtitle: Text('Date: ${transaction['date']}'),
                  trailing: DropdownButton<String>(
                    value: transaction['category'],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        updateCategory(transaction['transaction_id'], newValue);
                      }
                    },
                    items: <String>[
                      'Education',
                      'Entertainment',
                      'Food',
                      'Uncategorized'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
/ /
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  // Fetch transactions with 'Uncategorized' category
  Future<void> fetchTransactions() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('category', isEqualTo: 'Uncategorized')
          .get();

      setState(() {
        transactions = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    }
  }

  // Update the category of the transaction
  Future<void> updateCategory(String transactionId, String newCategory) async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('transaction_id', isEqualTo: transactionId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'category': newCategory});
      }

      fetchTransactions(); // Refresh list after update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000957), // Background color set to blue
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 242, 243),
        title: const Text(
          'Unrecognized Category',
          style: TextStyle(color: Color.fromARGB(255, 19, 19, 19)),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                var transaction = transactions[index];
                return Card(
                  color: Colors.blue[50], // Light blue background for each item
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      'Amount: ₹${transaction['amount']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Date: ${transaction['date']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: DropdownButton<String>(
                      value: transaction['category'],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          updateCategory(
                              transaction['transaction_id'], newValue);
                        }
                      },
                      items: <String>[
                        'Education',
                        'Entertainment',
                        'Food',
                        'Uncategorized'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myfirstapp/dashboard.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  // Fetch transactions with 'Uncategorized' category
  Future<void> fetchTransactions() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('category', isEqualTo: 'Uncategorized')
          .get();

      setState(() {
        transactions = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    }
  }

  // Update the category of the transaction
  Future<void> updateCategory(String transactionId, String newCategory) async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('transaction_id', isEqualTo: transactionId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'category': newCategory});
      }

      fetchTransactions(); // Refresh list after update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000957), // Background color set to blue
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 239, 240, 240),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 18, 17, 17)),
          onPressed: () {
            // Navigate back to the Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          },
        ),
        title: const Text(
          'Unrecognized Category',
          style: TextStyle(color: Color.fromARGB(255, 15, 15, 15)),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                var transaction = transactions[index];
                return Card(
                  color: Colors.blue[50], // Light blue background for each item
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      'Amount: ₹${transaction['amount']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Date: ${transaction['date']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: DropdownButton<String>(
                      value: transaction['category'],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          updateCategory(
                              transaction['transaction_id'], newValue);
                        }
                      },
                      items: <String>[
                        'Education',
                        'Entertainment',
                        'Food',
                        'Utilities',
                        'Transportation',
                        'Income',
                        'Other',
                        'Uncategorized'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}