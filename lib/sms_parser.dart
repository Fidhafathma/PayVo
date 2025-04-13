/*import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';


class SMSParser {
  final SmsQuery _query = SmsQuery();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> trustedSenders = {}; // ✅ Stores trusted senders

  
  /// *Parse and store transactions*
  Future<void> fetchAndStoreTransactions() async {
    var permission = await Permission.sms.request();
    if (permission.isDenied || permission.isPermanentlyDenied) 
    { debugPrint("SMS permission denied!!");
      return;}

    // ✅ Get the logged-in user's UID
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      debugPrint("No user logged in!!");
      return;}

    // ✅ Load trusted senders before processing SMS
    await _loadTrustedSenders();

    List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
    );

    for (var message in messages) {
      if (_isBankMessage(message.body!) && _isValidSender(message.address!)) {
        Map<String, dynamic>? transaction =
            extractTransactionDetails(message.body!);
        if (transaction != null) {
          bool exists = await transactionExists(userId, transaction["refNo"]);
          if (!exists) {
            transaction["user_id"] = userId; // Store user_id
            await storeTransaction(userId, transaction);
            debugPrint("Transaction stored:${transaction["refNo"]}");
          }
        }
      }
    }
  }

  /// *Load Trusted Senders from Firestore*
  Future<void> _loadTrustedSenders() async {
    try {
      QuerySnapshot senderDocs =
          await _firestore.collection("Trusted_senders").get();
      trustedSenders = senderDocs.docs
          .map((doc) => doc["Sender_id"].toString().toLowerCase())
          .toSet();
    } catch (e) {
      return;
    }
  }

  /// *Check if the SMS contains banking transaction keywords*
  bool _isBankMessage(String body) {
    return RegExp(
            r"\b(credited|debited|upi txn|transaction id|txn|received|sent|withdrawn)\b",
            caseSensitive: false)
        .hasMatch(body);
  }

  /// *Check if the sender is in the Trusted Senders list*
  bool _isValidSender(String? sender) {
    if (sender == null) return false;
    return trustedSenders.contains(sender.toLowerCase());
  }

  /// *Extract transaction details from the SMS body*
  Map<String, dynamic>? extractTransactionDetails(String body) {
    String lowerBody = body.toLowerCase();

    // ✅ Find first occurrence of "credit" and "debit"
    int creditIndex =
        lowerBody.indexOf(RegExp(r'\bcredit|credited|received\b'));
    int debitIndex = lowerBody.indexOf(RegExp(r'\bdebit|debited|sent\b'));

    // ✅ Determine type based on first occurrence
    String type = "unknown";
    if (creditIndex != -1 && (debitIndex == -1 || creditIndex < debitIndex)) {
      type = "credit";
    }
    if (debitIndex != -1 && (creditIndex == -1 || debitIndex < creditIndex)) {
      type = "debit";
    }

    // ✅ Extract amount
    RegExp amountRegex = RegExp(r'(?:₹|Rs\.?|INR)\s?([\d,]+\.?\d*)');
    Match? amountMatch = amountRegex.firstMatch(body);
    double? amount = amountMatch != null
        ? double.parse(amountMatch.group(1)!.replaceAll(",", ""))
        : null;

    // ✅ Extract reference number (first 12-digit number)
    RegExp refNoRegex = RegExp(r'\b\d{10,16}\b');
    Match? refNoMatch = refNoRegex.firstMatch(body);
    String? refNo = refNoMatch?.group(0);

    // ✅ Extract and format date
    String transactionDate = extractDateAsString(body);

    // ✅ Assign category
    String category = matchCategory(body);

    if (amount != null && refNo != null && type != "unknown") {
      return {
        "amount": amount,
        "date": transactionDate,
        "refNo": refNo,
        "type": type,
        "category": category,
        "user_id": FirebaseAuth.instance.currentUser?.uid,
      };
    }

    return null;
  }

  /// *Extracts date from SMS and returns formatted date string*
  String extractDateAsString(String message) {
    List<String> datePatterns = [
      r"\b\d{1,2}[-/ ]?[A-Za-z]{3}[-/ ]?\d{2,4}\b", // Matches "21-FEB-2025" or "21/FEB/2025"
      r"\b\d{1,2}/\d{1,2}/\d{2,4}\b", // Matches "21/02/2025"
      r"\b[A-Za-z]{3} \d{1,2},? \d{4}\b" // Matches "FEB 21, 2025"
    ];

    for (var pattern in datePatterns) {
      RegExp regex = RegExp(pattern, caseSensitive: false);
      Match? match = regex.firstMatch(message);
      if (match != null) {
        return match.group(0)!;
      }
    }

    return DateTime.now().toString(); // Fallback: Current date
  }

  /// *Categorize transaction based on keywords*
  String matchCategory(String message) {
    Map<String, String> categories = {
      "amazon": "Shopping",
      "flipkart": "Shopping",
      "swiggy": "Food",
      "zomato": "Food",
      "petrol": "Transport",
      "fuel": "Transport",
      "metro": "Transport",
      "atm": "Cash Withdrawal",
      "upi": "UPI Transfer",
      "electricity": "Utilities",
    };

    for (var keyword in categories.keys) {
      if (message.toLowerCase().contains(keyword)) {
        return categories[keyword]!;
      }
    }

    return "Uncategorized";
  }

  /// **Check if a transaction with the same refNo already exists**
  Future<bool> transactionExists(String userId, String refNo) async {
    var result = await _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .where("refNo", isEqualTo: refNo)
        .get();
    return result.docs.isNotEmpty;
  }

  /// *Store the extracted transaction in Firestore*
  Future<void> storeTransaction(String userId, Map<String, dynamic> transaction) async {
  try {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .add(transaction);
    debugPrint("✅ Transaction stored: ${transaction["refNo"]}");
  } catch (e) {
    debugPrint("❌ Firestore Error: $e");
  }
}

}

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer'; // For console logging

class SMSParser {
  final SmsQuery _query = SmsQuery();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> trustedSenders = {}; // ✅ Stores trusted senders

  /// *Manually fetch and store transactions*
  Future<void> fetchAndStoreTransactions() async {
    var permission = await Permission.sms.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      log("❌ SMS permission denied!");
      return;
    }

    // ✅ Get the logged-in user's UID
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      log("❌ No user logged in!");
      return;
    }

    // ✅ Load trusted senders before processing SMS
    await _loadTrustedSenders();

    // ✅ Fetch all SMS messages
    List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
    );

    log("📩 Total SMS fetched: ${messages.length}");

    for (var message in messages) {
      log("📨 SMS from: ${message.address} | Body: ${message.body}");

      if (_isBankMessage(message.body!) && _isValidSender(message.address!)) {
        Map<String, dynamic>? transaction =
            extractTransactionDetails(message.body!);

        if (transaction != null) {
          bool exists = await transactionExists(userId, transaction["refNo"]);
          if (!exists) {
            transaction["user_id"] = userId; // Store user_id
            await storeTransaction(userId, transaction);
            log("✅ Transaction stored: ${transaction["refNo"]}");
          } else {
            log("⚠ Transaction already exists: ${transaction["refNo"]}");
          }
        }
      }
    }
  }

  /// *Load Trusted Senders from Firestore*
  Future<void> _loadTrustedSenders() async {
    try {
      QuerySnapshot senderDocs =
          await _firestore.collection("Trusted_senders").get();
      trustedSenders = senderDocs.docs
          .map((doc) => doc["Sender_id"].toString().toLowerCase())
          .toSet();
    } catch (e) {
      log("❌ Error loading trusted senders: $e");
    }
  }

  /// *Check if the SMS contains banking transaction keywords*
  bool _isBankMessage(String body) {
    return RegExp(
            r"\b(credited|debited|upi txn|transaction id|txn|received|sent|withdrawn)\b",
            caseSensitive: false)
        .hasMatch(body);
  }

  /// *Check if the sender is in the Trusted Senders list*
  bool _isValidSender(String? sender) {
    if (sender == null) return false;
    return trustedSenders.contains(sender.toLowerCase());
  }

  /// *Extract transaction details from the SMS body*
  Map<String, dynamic>? extractTransactionDetails(String body) {
    String lowerBody = body.toLowerCase();

    // ✅ Find first occurrence of "credit" and "debit"
    int creditIndex =
        lowerBody.indexOf(RegExp(r'\bcredit|credited|received\b'));
    int debitIndex = lowerBody.indexOf(RegExp(r'\bdebit|debited|sent\b'));

    // ✅ Determine type based on first occurrence
    String type = "unknown";
    if (creditIndex != -1 && (debitIndex == -1 || creditIndex < debitIndex)) {
      type = "income";
    }
    if (debitIndex != -1 && (creditIndex == -1 || debitIndex < creditIndex)) {
      type = "expense";
    }

    // ✅ Extract amount
    RegExp amountRegex = RegExp(r'(?:₹|Rs\.?|INR)\s?([\d,]+\.?\d*)');
    Match? amountMatch = amountRegex.firstMatch(body);
    double? amount = amountMatch != null
        ? double.parse(amountMatch.group(1)!.replaceAll(",", ""))
        : null;

    // ✅ Extract reference number (first 12-digit number)
    RegExp refNoRegex = RegExp(r'\b\d{10,16}\b');
    Match? refNoMatch = refNoRegex.firstMatch(body);
    String? refNo = refNoMatch?.group(0);

    // ✅ Extract and format date
    DateTime transactionDate = DateTime.now(); // Use current date as fallback

    // ✅ Assign category
    String category = matchCategory(body);

    if (amount != null && refNo != null && type != "unknown") {
      return {
        "amount": amount,
        "date": transactionDate, // Keep Firestore format unchanged
        "refNo": refNo,
        "type": type,
        "category": category,
        "user_id": FirebaseAuth.instance.currentUser?.uid,
      };
    }

    return null;
  }

  /// *Categorize transaction based on keywords*
  String matchCategory(String message) {
    Map<String, String> categories = {
      "amazon": "Shopping",
      "flipkart": "Shopping",
      "swiggy": "Food",
      "zomato": "Food",
      "petrol": "Transport",
      "fuel": "Transport",
      "atm": "Cash Withdrawal",
      "upi": "UPI Transfer",
      "electricity": "Utilities",
    };

    for (var keyword in categories.keys) {
      if (message.toLowerCase().contains(keyword)) {
        return categories[keyword]!;
      }
    }

    return "Uncategorized";
  }

  /// **Check if a transaction with the same refNo already exists**
  Future<bool> transactionExists(String userId, String refNo) async {
    var result = await _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .where("refNo", isEqualTo: refNo)
        .get();
    return result.docs.isNotEmpty;
  }

  /// *Store the extracted transaction in Firestore*
  Future<void> storeTransaction(
      String userId, Map<String, dynamic> transaction) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .add(transaction);
      log("✅ Transaction successfully stored: ${transaction["refNo"]}");
    } catch (e) {
      log("❌ Firestore Error: $e");
    }
  }
}

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SMSParser {
  final SmsQuery _query = SmsQuery();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> trustedSenders = {}; // ✅ Stores trusted senders

  /// *Load Trusted Senders from Firestore*
  Future<void> loadTrustedSenders() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("Trusted_senders").get();

      trustedSenders = querySnapshot.docs
          .map((doc) {
            var data = doc.data() as Map<String, dynamic>?; // Ensure it's a Map
            if (data != null && data.containsKey('Sender_id')) {
              return data['Sender_id'].toString().toLowerCase();
            }
            return null; // Ignore invalid entries
          })
          .where((sender) => sender != null) // Remove null values
          .cast<String>()
          .toSet();

      debugPrint("✅ Trusted Senders Loaded: $trustedSenders");
    } catch (e) {
      debugPrint("❌ Error loading trusted senders: $e");
    }
  }

  /// *Check if SMS is from a valid sender*
  bool _isValidSender(String? sender) {
    if (sender == null) return false;
    return trustedSenders.any((trusted) => sender.toLowerCase().contains(trusted));
  }

  /// *Check if the SMS contains credit or debit keywords*
  bool _isBankMessage(String body) {
    return RegExp(
            r"\b(credit|credited|debit|debited|received|sent|upi txn|transaction id|txn|withdrawn)\b",
            caseSensitive: false)
        .hasMatch(body);
  }

  /// *Extract transaction details from the SMS body*
  Map<String, dynamic>? extractTransactionDetails(String body) {
    String lowerBody = body.toLowerCase();

    // ✅ Find first occurrence of "credit" and "debit"
    int creditIndex =
        lowerBody.indexOf(RegExp(r'\bcredit|credited|received\b'));
    int debitIndex = lowerBody.indexOf(RegExp(r'\bdebit|debited|sent\b'));

    // ✅ Determine type based on first occurrence
    String type = "unknown";
    if (creditIndex != -1 && (debitIndex == -1 || creditIndex < debitIndex)) {
      type = "income";
    }
    if (debitIndex != -1 && (creditIndex == -1 || debitIndex < creditIndex)) {
      type = "expense";
    }

    // ✅ Extract amount
    RegExp amountRegex = RegExp(r'(?:₹|Rs\.?|INR)\s?([\d,]+\.?\d*)');
    Match? amountMatch = amountRegex.firstMatch(body);
    double? amount = amountMatch != null
        ? double.parse(amountMatch.group(1)!.replaceAll(",", ""))
        : null;

    // ✅ Extract reference number (first 12-digit number)
    RegExp refNoRegex = RegExp(r'\b\d{10,16}\b');
    Match? refNoMatch = refNoRegex.firstMatch(body);
    String? refNo = refNoMatch?.group(0);

    // ✅ Extract and format date
    DateTime transactionDate = DateTime.now(); // Use current date as fallback

    // ✅ Assign category
    String category = matchCategory(body);

    if (amount != null && refNo != null && type != "unknown") {
      return {
        "amount": amount,
        "date": transactionDate, // Keep Firestore format unchanged
        "refNo": refNo,
        "type": type,
        "category": category,
        "user_id": FirebaseAuth.instance.currentUser?.uid,
      };
    }

    return null;
  }

  /// *Extracts date from SMS and returns formatted DateTime*
  DateTime? extractDateFromSMS(String message) {
    List<String> datePatterns = [
      r"\b\d{1,2}[-/ ]?[A-Za-z]{3}[-/ ]?\d{2,4}\b", // 25-FEB-2025 or 25/02/2025
      r"\b\d{1,2}/\d{1,2}/\d{2,4}\b", // 25/02/2025
      r"\b[A-Za-z]{3} \d{1,2},? \d{4}\b" // FEB 25, 2025
    ];

    for (var pattern in datePatterns) {
      RegExp regex = RegExp(pattern, caseSensitive: false);
      Match? match = regex.firstMatch(message);
      if (match != null) {
        return DateTime.tryParse(match.group(0)!);
      }
    }

    return null; // If no valid date found, return null
  }

  /// *Categorize transaction based on keywords*
  String matchCategory(String message) {
    Map<String, String> categories = {
      "amazon": "Shopping",
      "flipkart": "Shopping",
      "swiggy": "Food",
      "zomato": "Food",
      "petrol": "Transport",
      "fuel": "Transport",
      "atm": "Cash Withdrawal",
      "upi": "UPI Transfer",
      "electricity": "Utilities",
    };

    for (var keyword in categories.keys) {
      if (message.toLowerCase().contains(keyword)) {
        return categories[keyword]!;
      }
    }

    return "Uncategorized";
  }

  /// *Check if transaction already exists (by refNo)*
  Future<bool> transactionExists(String userId, String refNo) async {
    var result = await _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .where("transaction_id", isEqualTo: refNo)
        .get();
    return result.docs.isNotEmpty;
  }
 
  /// *Store extracted transaction in Firestore*
  Future<void> storeTransaction(String userId, Map<String, dynamic> transaction) async {
    try {
      debugPrint("📝 Attempting to store transaction: $transaction");
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .add(transaction);
      debugPrint("✅ Transaction stored: ${transaction["transaction_id"]}");
    } catch (e) {
      debugPrint("❌ Firestore Error: $e");
    }
  }

  /// *Fetch and Store Transactions*
  Future<void> fetchAndStoreTransactions() async {
    var permission = await Permission.sms.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      debugPrint("❌ SMS permission denied!!");
      return;
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      debugPrint("❌ No user logged in!!");
      return;
    }

    await loadTrustedSenders(); // Load trusted senders before parsing

    List<SmsMessage> messages = await _query.querySms(kinds: [SmsQueryKind.inbox]);

    for (var message in messages) {
      if (_isBankMessage(message.body!) && _isValidSender(message.address)) {
        debugPrint("📩 Processing SMS from ${message.address}: ${message.body}");

        Map<String, dynamic>? transaction = extractTransactionDetails(message.body!);
                    print("1JHGDHSGHGDHJFHRGHJGHJRGJHDJVJBCBVBHGJRG12553676547846869871836761764648464888723818478478127");

        if (transaction != null) {
          bool exists = await transactionExists(userId, transaction["transaction_id"]);
          if (!exists) {
            transaction["user_id"] = userId; // ✅ Store user_id
            print("2JHGDHSGHGDHJFHRGHJGHJRGJHDJVJBCBVBHGJRG12553676547846869871836761764648464888723818478478127");
            await storeTransaction(userId, transaction);
          } else {
            debugPrint("🔄 Transaction already exists: ${transaction["transaction_id"]}");
          }
        }
        else{
                      print("3JHGDHSGHGDHJFHRGHJGHJRGJHDJVJBCBVBHGJRG12553676547846869871836761764648464888723818478478127");

        }
      }
    }
    debugPrint("✅ SMS parsing completed!");
  }
}
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Required for date parsing

class SMSParser {
  final SmsQuery _query = SmsQuery();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchAndStoreTransactions(String userId) async {
    var permission = await Permission.sms.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      print("SMS permission denied");
      return;
    }

    List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
    );

    for (var message in messages) {
      if (isBankMessage(message.body!)) {
        Map<String, dynamic>? transaction =
            extractTransactionDetails(message.body!);
        if (transaction != null) {
          bool exists =
              await transactionExists(userId, transaction["transaction_id"]);
          if (!exists) {
            transaction["user_id"] = userId; // Associate transaction with user
            transaction["category"] =
                matchCategory(message.body!); // Categorize transaction
            await storeTransaction(userId, transaction);
          }
        }
      }
    }
  }

  bool isBankMessage(String body) {
    return body.toLowerCase().contains("credited") ||
        body.toLowerCase().contains("debited") ||
        body.toLowerCase().contains("upi txn") ||
        body.toLowerCase().contains("transaction id") ||
        body.toLowerCase().contains("txn");
  }

  Map<String, dynamic>? extractTransactionDetails(String body) {
    String lowerBody = body.toLowerCase();

    // Determine if it's credit or debit
    String type = lowerBody.contains("credited") ? "credit" : "debit";

    // Extract amount and date
    /*RegExp amountDateRegex = RegExp(
      r'(?:NR|Rs\.?|Rs:|INR)\s?(\d+\.?\d*) .*?on\s(\d{2}-[A-Za-z]{3}-\d{4})',
      caseSensitive: false,
    );
    Match? amountDateMatch = amountDateRegex.firstMatch(body);
    */
    /*RegExp amountRegex = RegExp(
  r'(?:Rs\.?|Rs:|INR|NR)\s?(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?)',
  caseSensitive: false
);*/
RegExp amountRegex = RegExp(
  r'(?:Rs\.?|Rs:|INR|₹|NR)\s?([\d,]+\.?\d*)',
  caseSensitive: false
);
     Match? amountMatch=amountRegex.firstMatch(body);
    RegExp dateRegex = RegExp(
      r'(\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4}|\d{1,2}[A-Za-z]{3,}[-/]?\d{2,4})',
      caseSensitive: false,
    );
    Match? dateMatch = dateRegex.firstMatch(body);
    // Extract first 12-digit number as refNo
    RegExp refNoRegex = RegExp(r'\b\d{12}\b');
    Match? refNoMatch = refNoRegex.firstMatch(body);

    if (amountMatch != null && dateMatch != null && refNoMatch != null) {
      String dateStr = dateMatch.group(0)!;
      DateTime? parsedDate = parseDate(dateStr);
      if (parsedDate == null) return null; // Skip if date parsing fails

      return {
        "amount": double.parse(amountMatch.group(1)!),
        "date": parsedDate.toIso8601String(),
        "transaction_id":
            refNoMatch.group(0)!, // Extracts the first 12-digit number
        "type": type,
      };
    }

    return null;
  }

  DateTime? parseDate(String dateStr) {
    List<String> formats = [
      "dd-MM-yy", "dd/MM/yy", "dd.MM.yy", // 10-01-25, 10/01/25, 10.01.25
      "dd-MM-yyyy", "dd/MM/yyyy", "dd.MM.yyyy", // 10-01-2025, 10/01/2025
      "dd-MMM-yy", "dd-MMM-yyyy", // 25-FEB-25, 25-FEB-2025
      "ddMMMyy", "ddMMMyyyy", // 11Jan25, 11Jan2025
      "yyyy-MM-dd", "yyyy/MM/dd", "yyyy.MM.dd" // 2025-01-10, 2025/01/10
    ];

    for (var format in formats) {
      try {
        return DateFormat(format).parse(dateStr);
      } catch (e) {
        continue; // Try next format if parsing fails
      }
    }

    return null; // Return null if all formats fail
  }

  /// Categorizes transactions based on keywords
  String matchCategory(String message) {
    Map<String, String> categories = {
      "amazon": "Shopping",
      "flipkart": "Shopping",
      "myntra": "Shopping",
      "swiggy": "Food",
      "zomato": "Food",
      "tp manoharan": "Food",
      "bigbasket": "Groceries",
      "grofers": "Groceries",
      "petrol": "Transport",
      "fuel": "Transport",
      "metro": "Transport",
      "ola": "Transport",
      "uber": "Transport",
      "atm": "Cash Withdrawal",
      //"upi": "UPI Transfer",
      "electricity": "Utilities",
      "water bill": "Utilities",
      "gas bill": "Utilities",
      "insurance": "Insurance",
      "loan emi": "Loan Payment",
      "rent": "Rent",
      "salary": "Income",
      "interest": "Income",
    };

    for (var keyword in categories.keys) {
      if (message.toLowerCase().contains(keyword)) {
        return categories[keyword]!;
      }
    }
    return "Uncategorized";
  }

  Future<bool> transactionExists(String userId, String refNo) async {
    var result = await _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .where("user_id", isEqualTo: userId)
        .where("transaction_id", isEqualTo: refNo)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> storeTransaction(
      String userID, Map<String, dynamic> transaction) async {
    try {
      await _firestore
          .collection("users")
          .doc(userID)
          .collection("transactions")
          .add(transaction);
      print("Transaction stored: $transaction");
    } catch (e) {
      print("Error storing transaction: $e");
    }
  }

  Stream<QuerySnapshot> getTransactionsStream(String userId) {
    return _firestore
        /*.collection("transactions")
        .where("user_id", isEqualTo: userId)
*/
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .where("user_Id", isEqualTo: userId)
        .snapshots();
  }
}

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SMSParser {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// *🔄 Fetch & Store Transactions (Parse All SMS Repeatedly)*
  Future<void> fetchAndStoreTransactions(String userId) async {
    var permission = await Permission.sms.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      print("❌ SMS permission denied");
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      print("❌ No authenticated user. Please log in.");
      return;
    }

    try {
      SmsQuery query = SmsQuery(); // ✅ Always fetch fresh SMS
      List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.inbox], // ✅ Fetch all messages
      );

      for (var message in messages) {
        if (isBankMessage(message.body!)) {
          Map<String, dynamic>? transaction = extractTransactionDetails(message.body!);
          if (transaction != null) {
            // ✅ Check if transaction exists before storing
            bool exists = await transactionExists(userId, transaction["transaction_id"]);
            if (!exists) {
              transaction["user_id"] = userId;
              transaction["category"] = matchCategory(message.body!);
              await storeTransaction(userId, transaction);
            }
          }
        }
      }
      print("✅ SMS Parsing Completed!");
    } catch (e) {
      print("❌ Error during SMS parsing: $e");
    }
  }

  /// *🔍 Identify if SMS is a bank message*
  bool isBankMessage(String body) {
    return RegExp(
      r"\b(credited|credit|received|added|debited|debit|send|sent|withdrawn|upi txn|transaction id|txn)\b",
      caseSensitive: false).hasMatch(body);
  }

  /// *📌 Extract transaction details*
  Map<String, dynamic>? extractTransactionDetails(String body) {
    String lowerBody = body.toLowerCase();

    // ✅ Determine transaction type (credit/debit)
    Map<String, String> keywordMap = {
      "credited": "credit", "credit": "credit", "received": "credit", "added": "credit",
      "debited": "debit", "debit": "debit", "send": "debit", "sent": "debit", "withdrawn": "debit"
    };

    String type = "";
    int firstIndex = lowerBody.length;

    for (var entry in keywordMap.entries) {
      int index = lowerBody.indexOf(entry.key);
      if (index != -1 && index < firstIndex) {
        firstIndex = index;
        type = entry.value;
      }
    }

    if (type.isEmpty) return null; // Ignore if no valid keyword

    // ✅ Extract amount
    RegExp amountRegex = RegExp(r'(?:Rs\.?|Rs:|INR|₹|NR)\s?([\d,]+\.?\d*)', caseSensitive: false);
    Match? amountMatch = amountRegex.firstMatch(body);

    // ✅ Extract date
    RegExp dateRegex = RegExp(
      r'(\d{1,2}[-/.](?:\d{1,2}|[A-Za-z]{3})[-/.]\d{2,4}(?:\s\d{2}:\d{2}:\d{2})?)',
      caseSensitive: false
    );
    Match? dateMatch = dateRegex.firstMatch(body);

    // ✅ Extract reference number
    RegExp refNoRegex = RegExp(r'\b\d{12,16}\b'); // 12-16 digit transaction ID
    Match? refNoMatch = refNoRegex.firstMatch(body);

    if (amountMatch != null && dateMatch != null && refNoMatch != null) {
      String dateStr = dateMatch.group(0)!;
      DateTime? parsedDate = parseDate(dateStr);
      if (parsedDate == null) return null; // Skip if date parsing fails

      return {
        "amount": double.parse(amountMatch.group(1)!.replaceAll(",", "")),
        "date": parsedDate.toIso8601String(),
        "transaction_id": refNoMatch.group(0)!,
        "type": type,
      };
    }

    return null;
  }

  /// *🗓 Parse various date formats*
  DateTime? parseDate(String dateStr) {
    List<String> formats = [
      "dd-MM-yy", "dd/MM/yy", "dd.MM.yy", 
      "dd-MM-yyyy", "dd/MM/yyyy", "dd.MM.yyyy", 
      "dd-MMM-yy", "dd-MMM-yyyy", "ddMMMyy", "ddMMMyyyy", 
      "yyyy-MM-dd", "yyyy/MM/dd", "yyyy.MM.dd", 
      "dd-MM-yyyy HH:mm:ss", "dd/MM/yyyy HH:mm:ss"
    ];

    for (var format in formats) {
      try {
        return DateFormat(format).parse(dateStr);
      } catch (e) {
        continue;
      }
    }

    return null;
  }

  /// *🛒 Categorize transactions*
  String matchCategory(String message) {
    Map<String, String> categories = {
      "amazon": "Shopping", "flipkart": "Shopping", "myntra": "Shopping",
      "swiggy": "Food", "zomato": "Food", "bigbasket": "Groceries",
      "petrol": "Transport", "fuel": "Transport", "atm": "Cash Withdrawal",
      "upi": "UPI Transfer", "electricity": "Utilities", "insurance": "Insurance",
      "loan emi": "Loan Payment", "rent": "Rent", "salary": "Income"
    };

    for (var keyword in categories.keys) {
      if (message.toLowerCase().contains(keyword)) {
        return categories[keyword]!;
      }
    }
    return "Uncategorized";
  }

  /// *🔎 Check if transaction already exists*
  Future<bool> transactionExists(String userId, String refNo) async {
    try {
      var result = await _firestore
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .where("transaction_id", isEqualTo: refNo)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print("❌ Error checking existing transaction: $e");
      return false;
    }
  }

  /// *💾 Store transaction in Firestore*
  Future<void> storeTransaction(String userId, Map<String, dynamic> transaction) async {
    try {
      print("📝 Attempting to store transaction: $transaction");

      await _firestore
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .add(transaction);

      print("✅ Transaction stored successfully: ${transaction["transaction_id"]}");
    } catch (e) {
      print("❌ Firestore Write Error: $e");
    }
  }

  /// *📊 Get transaction stream*
  Stream<QuerySnapshot> getTransactionsStream(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .snapshots();
  }
}
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class SMSParser {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> trustedSenders = {}; // ✅ Stores trusted senders
  /// *Load Trusted Senders from Firestore*
  Future<void> loadTrustedSenders() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("Trusted_senders").get();

      trustedSenders = querySnapshot.docs
          .map((doc) {
            var data = doc.data() as Map<String, dynamic>?; // Ensure it's a Map
            if (data != null && data.containsKey('Sender_id')) {
              return data['Sender_id'].toString().toLowerCase();
            }
            return null; // Ignore invalid entries
          })
          .where((sender) => sender != null) // Remove null values
          .cast<String>()
          .toSet();

      debugPrint("✅ Trusted Senders Loaded: $trustedSenders");
    } catch (e) {
      debugPrint("❌ Error loading trusted senders: $e");
    }
  }

  /// *Check if SMS is from a valid sender*
  bool _isValidSender(String? sender) {
    if (sender == null) return false;
    return trustedSenders
        .any((trusted) => sender.toLowerCase().contains(trusted));
  }

  /// *🔄 Fetch & Store Transactions (Parse All SMS Repeatedly)*
  Future<void> fetchAndStoreTransactions(String userId) async {
    var permission = await Permission.sms.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      print("❌ SMS permission denied");
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      print("❌ No authenticated user. Please log in.");
      return;
    }
    await loadTrustedSenders(); // Load trusted senders before parsing

    try {
      SmsQuery query = SmsQuery(); // ✅ Always fetch fresh SMS
      List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.inbox], // ✅ Fetch all messages
      );

      for (var message in messages) {
        if (isBankMessage(message.body!) && _isValidSender(message.address)) {
          Map<String, dynamic>? transaction =
              extractTransactionDetails(message.body!);
          if (transaction != null) {
            // ✅ Check if transaction exists before storing
            bool exists =
                await transactionExists(userId, transaction["transaction_id"]);
            if (!exists) {
              transaction["user_id"] = userId;
              transaction["category"] = matchCategory(message.body!);
              await storeTransaction(userId, transaction);
            }
          }
        }
      }
      print("✅ SMS Parsing Completed!");
    } catch (e) {
      print("❌ Error during SMS parsing: $e");
    }
  }

  /// *🔍 Identify if SMS is a bank message*
  bool isBankMessage(String body) {
    return RegExp(
            r"\b(credited|credit|received|added|debited|debit|send|sent|withdrawn|upi txn|transaction id|txn)\b",
            caseSensitive: false)
        .hasMatch(body);
  }

  /// *📌 Extract transaction details*
  Map<String, dynamic>? extractTransactionDetails(String body) {
    String lowerBody = body.toLowerCase();

    // ✅ Determine transaction type (credit/debit)
    Map<String, String> keywordMap = {
      "credited": "credit",
      "credit": "credit",
      "received": "credit",
      "added": "credit",
      "debited": "debit",
      "debit": "debit",
      "send": "debit",
      "sent": "debit",
      "withdrawn": "debit"
    };

    String type = "";
    int firstIndex = lowerBody.length;

    for (var entry in keywordMap.entries) {
      int index = lowerBody.indexOf(entry.key);
      if (index != -1 && index < firstIndex) {
        firstIndex = index;
        type = entry.value;
      }
    }

    if (type.isEmpty) return null; // Ignore if no valid keyword

    // ✅ Extract amount
    RegExp amountRegex = RegExp(r'(?:Rs\.?|Rs:|INR|₹|NR)\s?([\d,]+\.?\d*)',
        caseSensitive: false);
    Match? amountMatch = amountRegex.firstMatch(body);

    // ✅ Extract date (Updated regex for various formats)
    RegExp dateRegex = RegExp(
        r'\b(\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4}|\d{4}[-/.]\d{2}[-/.]\d{2}|(\d{1,2}\s*[A-Za-z]{3,}\s*\d{2,4}))\b',
        caseSensitive: false);
    Match? dateMatch = dateRegex.firstMatch(body);

    // ✅ Extract reference number
    RegExp refNoRegex = RegExp(r'\b\d{12,16}\b'); // 12-16 digit transaction ID
    Match? refNoMatch = refNoRegex.firstMatch(body);

    if (amountMatch != null && dateMatch != null && refNoMatch != null) {
      String dateStr = dateMatch.group(0)!;
      DateTime? parsedDate = parseDate(dateStr);
      if (parsedDate == null) return null; // Skip if date parsing fails

      return {
        "amount": double.parse(amountMatch.group(1)!.replaceAll(",", "")),
        "date": parsedDate.toIso8601String(),
        "transaction_id": refNoMatch.group(0)!,
        "type": type,
      };
    }

    return null;
  }

  /// *🗓 Parse various date formats*
  DateTime? parseDate(String dateStr) {
    List<String> formats = [
      "dd-MM-yy",
      "dd/MM/yy",
      "dd.MM.yy",
      "dd-MM-yyyy",
      "dd/MM/yyyy",
      "dd.MM.yyyy",
      "dd-MMM-yy",
      "dd-MMM-yyyy",
      "ddMMMyy",
      "ddMMMyyyy",
      "yyyy-MM-dd",
      "yyyy/MM/dd",
      "yyyy.MM.dd",
      "dd-MM-yyyy HH:mm:ss",
      "dd/MM/yyyy HH:mm:ss"
    ];

    for (var format in formats) {
      try {
        DateFormat formatter = DateFormat(format);
        DateTime parsedDate =
            formatter.parse(dateStr, true).toUtc(); // Enforce UTC

        // Fix for yy -> Ensure it’s a 2000+ year
        if (parsedDate.year < 2000) {
          parsedDate = DateTime(
              parsedDate.year + 2000, parsedDate.month, parsedDate.day);
        }

        return parsedDate;
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// *🛒 Categorize transactions*
  String matchCategory(String message) {
    Map<String, String> categories = {
      "amazon": "Shopping",
      "flipkart": "Shopping",
      "myntra": "Shopping",
      "swiggy": "Food",
      "zomato": "Food",
      "bigbasket": "Groceries",
      "petrol": "Transport",
      "fuel": "Transport",
      "atm": "Cash Withdrawal",
      "upi": "UPI Transfer",
      "electricity": "Utilities",
      "insurance": "Insurance",
      "loan emi": "Loan Payment",
      "rent": "Rent",
      "salary": "Income"
    };

    for (var keyword in categories.keys) {
      if (message.toLowerCase().contains(keyword)) {
        return categories[keyword]!;
      }
    }
    return "Uncategorized";
  }

  /// *🔎 Check if transaction already exists*
  Future<bool> transactionExists(String userId, String refNo) async {
    try {
      var result = await _firestore
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .where("transaction_id", isEqualTo: refNo)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print("❌ Error checking existing transaction: $e");
      return false;
    }
  }

  /// *💾 Store transaction in Firestore*
  Future<void> storeTransaction(
      String userId, Map<String, dynamic> transaction) async {
    try {
      print("📝 Attempting to store transaction: $transaction");

      await _firestore
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .add(transaction);

      print(
          "✅ Transaction stored successfully: ${transaction["transaction_id"]}");
    } catch (e) {
      print("❌ Firestore Write Error: $e");
    }
  }

  /// *📊 Get transaction stream*
  Stream<QuerySnapshot> getTransactionsStream(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .snapshots();
  }
}

*/
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class SMSParser {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> trustedSenders = {}; // ✅ Stores trusted senders
  // Map<String, Set<String>> categoryKeywords = {}; // ✅ Dynamic Categories

  /// Load Trusted Senders from Firestore
  Future<void> loadTrustedSenders() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("Trusted_senders").get();

      trustedSenders = querySnapshot.docs
          .map((doc) {
            var data = doc.data() as Map<String, dynamic>?; // Ensure it's a Map
            if (data != null && data.containsKey('Sender_id')) {
              return data['Sender_id'].toString().toLowerCase();
            }
            return null; // Ignore invalid entries
          })
          .where((sender) => sender != null) // Remove null values
          .cast<String>()
          .toSet();

      debugPrint("✅ Trusted Senders Loaded: $trustedSenders");
    } catch (e) {
      debugPrint("❌ Error loading trusted senders: $e");
    }
  }

      /// Load Categories from Firestore
  /*Future<void> loadCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("Categories").get();

      categoryKeywords = {}; // Reset before loading

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('keywords')) {
          String category = doc.id; // Category name as document ID
          List<dynamic> keywords = data['keywords'];

          categoryKeywords[category] = keywords
              .map((keyword) => keyword.toString().toLowerCase())
              .toSet();
        }
      }

      debugPrint("✅ Categories Loaded: $categoryKeywords");
    } catch (e) {
      debugPrint("❌ Error loading categories: $e");
    }
  }*/

  /// Check if SMS is from a valid sender
  bool _isValidSender(String? sender) {
    if (sender == null) return false;
    return trustedSenders
        .any((trusted) => sender.toLowerCase().contains(trusted));
  }

  /// 🔄 Fetch & Store Transactions (Parse All SMS Repeatedly)
  Future<void> fetchAndStoreTransactions(String userId) async {
    var permission = await Permission.sms.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      print("❌ SMS permission denied");
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      print("❌ No authenticated user. Please log in.");
      return;
    }
    await loadTrustedSenders(); // Load trusted senders before parsing

    try {
      SmsQuery query = SmsQuery(); // ✅ Always fetch fresh SMS
      List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.inbox], // ✅ Fetch all messages
      );

      for (var message in messages) {
        if (isBankMessage(message.body!) && _isValidSender(message.address)) {
          Map<String, dynamic>? transaction =
              extractTransactionDetails(message.body!);
          if (transaction != null) {
            // ✅ Check if transaction exists before storing
            bool exists =
                await transactionExists(userId, transaction["transaction_id"]);
            if (!exists) {
              transaction["user_id"] = userId;
              transaction["category"] = matchCategory(message.body!);
              await storeTransaction(userId, transaction);
            }
          }
        }
      }
      print("✅ SMS Parsing Completed!");
    } catch (e) {
      print("❌ Error during SMS parsing: $e");
    }
  }

  /// 🔍 Identify if SMS is a bank message
  bool isBankMessage(String body) {
    return RegExp(
            r"\b(credited|credit|received|added|debited|debit|send|sent|withdrawn|upi txn|transaction id|txn)\b",
            caseSensitive: false)
        .hasMatch(body);
  }

  /// 📌 Extract transaction details
  Map<String, dynamic>? extractTransactionDetails(String body) {
    String lowerBody = body.toLowerCase();

    // ✅ Determine transaction type (credit/debit)
    Map<String, String> keywordMap = {
      "credited": "credit",
      "credit": "credit",
      "received": "credit",
      "added": "credit",
      "debited": "debit",
      "debit": "debit",
      "send": "debit",
      "sent": "debit",
      "withdrawn": "debit"
    };

    String type = "";
    int firstIndex = lowerBody.length;

    for (var entry in keywordMap.entries) {
      int index = lowerBody.indexOf(entry.key);
      if (index != -1 && index < firstIndex) {
        firstIndex = index;
        type = entry.value;
      }
    }

    if (type.isEmpty) return null; // Ignore if no valid keyword

    // ✅ Extract amount
    RegExp amountRegex = RegExp(r'(?:Rs\.?|Rs:|INR|₹|NR)\s?([\d,]+\.?\d*)',
        caseSensitive: false);
    Match? amountMatch = amountRegex.firstMatch(body);

    // ✅ Extract date (Updated regex for various formats)
    RegExp dateRegex = RegExp(
        r'\b(\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4}|\d{4}[-/.]\d{2}[-/.]\d{2}|(\d{1,2}\s*[A-Za-z]{3,}\s*\d{2,4}))\b',
        caseSensitive: false);
    Match? dateMatch = dateRegex.firstMatch(body);

    // ✅ Extract reference number
    /*RegExp refNoRegex = RegExp(r'\b\d{12,16}\b'); // 12-16 digit transaction ID
    Match? refNoMatch = refNoRegex.firstMatch(body);

    if (amountMatch != null && dateMatch != null && refNoMatch != null) {
      String dateStr = dateMatch.group(0)!;
      DateTime? parsedDate = parseDate(dateStr);
      if (parsedDate == null) return null; // Skip if date parsing fails

      return {
        "amount": double.parse(amountMatch.group(1)!.replaceAll(",", "")),
        "date": parsedDate.toIso8601String(),
        "transaction_id": refNoMatch.group(0)!,
        "type": type,
      };
    }

    return null;
    */
    // First try to find UPI ref no explicitly mentioned
//RegExp upiRefRegex = RegExp(r'(?:UPI.*?(?:Ref|TXN)[^\d]*)(\d{10,})', caseSensitive: false);
RegExp upiRefRegex = RegExp(
  r'(?:UPI.*?(?:Ref(?:[^\d]*)?|TXN[:\s/\\-]*))(\d{10,})',
  caseSensitive: false
);
Match? upiMatch = upiRefRegex.firstMatch(body);

String? transactionId;

if (upiMatch != null) {
  transactionId = upiMatch.group(1);
} else {
  // Fallback to any 12–16 digit number
  RegExp fallbackRefNoRegex = RegExp(r'\b\d{12,16}\b');
  Match? fallbackMatch = fallbackRefNoRegex.firstMatch(body);
  transactionId = fallbackMatch?.group(0);
}
if (amountMatch != null && dateMatch != null && transactionId != null) {
  String dateStr = dateMatch.group(0)!;
  DateTime? parsedDate = parseDate(dateStr);
  if (parsedDate == null) return null;

  return {
    "amount": double.parse(amountMatch.group(1)!.replaceAll(",", "")),
    "date": parsedDate.toIso8601String(),
    "transaction_id": transactionId,
    "type": type,
  };
}

  }

  /// 🗓 Parse various date formats
  DateTime? parseDate(String dateStr) {
    List<String> formats = [
      "dd-MM-yy",
      "dd/MM/yy",
      "dd.MM.yy",
      
      "dd-MM-yyyy",
      "dd/MM/yyyy",
      "dd.MM.yyyy",
      "dd-MMM-yy",
      "dd-MMM-yyyy",
      "ddMMMyy",
      "ddMMMyyyy",
      "yyyy-MM-dd",
      "yyyy/MM/dd",
      "yyyy.MM.dd",
      "dd-MM-yyyy HH:mm:ss",
      "dd/MM/yyyy HH:mm:ss"
    ];

    for (var format in formats) {
      try {
        DateFormat formatter = DateFormat(format);
        DateTime parsedDate =
            formatter.parse(dateStr, true).toUtc(); // Enforce UTC

        // Fix for yy -> Ensure it’s a 2000+ year
        if (parsedDate.year < 2000) {
          parsedDate = DateTime(
              parsedDate.year + 2000, parsedDate.month, parsedDate.day);
        }

        return parsedDate;
      } catch (e) {
        continue;
      }
    }
    return null;
  }
   /// 🛒 Dynamically Match Category from Firestore
  
  /*String matchCategory(String message) {
    String lowerMessage = message.toLowerCase();

    for (var category in categoryKeywords.entries) {
      for (var keyword in category.value) {
        if (lowerMessage.contains(keyword)) {
          return category.key; // ✅ Return first matching category
        }
      }
    }

    return "Uncategorized"; // Fallback
  }
*/

  /// 🛒 Categorize transactions
 /*String matchCategory(String message) {
    Map<String, String> categories = {
      "amazon": "Shopping",
      "flipkart": "Shopping",
      "myntra": "Shopping",
      "swiggy": "Food",
      "zomato": "Food",
      "bigbasket": "Shopping",
      "petrol": "Transport",
      "fuel": "Transport",
      "electricity": "Utilities",
      "insurance": "Utilities",
      "loan emi": "Utilities",
      "rent": "Utilities",
      "salary": "Income",
      "KSRTC": "Transport",
      "KTU": "Education",
      "market": "Shopping",
      "bazar": "Shopping",
      "Restaurant": "Food",
      "Hotel": "Food",
      "Movie": "Entertainment",
      "Theatre": "Entertainment",
      "Amusement Park": "Entertainment",
      "Mall": "Shopping"
    };

    for (var keyword in categories.keys) {
      if (message.toLowerCase().contains(keyword)) {
        return categories[keyword]!;
      }
    }
    return "Uncategorized";
  }*/
  String matchCategory(String message) {
  String lowerMessage = message.toLowerCase();
  print(lowerMessage);
  // First, check specific keywords
  Map<String, String> specificCategories = {
    "tp manoharan":"Food",
    "amazon": "Shopping",
    "flipkart": "Shopping",
    "myntra": "Shopping",
    "swiggy": "Food",
    "zomato": "Food",
    "bigbasket": "Shopping",
    "petrol": "Transport",
    "fuel": "Transport",
    "electricity": "Utilities", 
    "insurance": "Utilities",
    "loan emi":"Utilities",
    "rent": "Utilities",
    "salary": "Income",
    "ksrtc": "Transport",
    "ktu": "Education",
    "market": "Shopping",
    "bazar": "Shopping",
    "restaurant": "Food",
    "metro": "Transport",
    "hotel": "Food",
    "movie": "Entertainment",
    "theatre": "Entertainment",
    "amusement park": "Entertainment",
    "mall": "Shopping"
  };

  for (var keyword in specificCategories.keys) {
    if (lowerMessage.contains(keyword)) {
      return specificCategories[keyword]!;
    }
  }

  // If no specific match, check generic fallback terms
  if (lowerMessage.contains("atm")) return "ATM Withdrawal";
  if (lowerMessage.contains("upi")) return "UPI Transfer";

  return "Uncategorized";
}

  /// 🔎 Check if transaction already exists
  Future<bool> transactionExists(String userId, String refNo) async {
    try {
      var result = await _firestore
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .where("transaction_id", isEqualTo: refNo)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print("❌ Error checking existing transaction: $e");
      return false;
    }
  }
  

  /// 💾 Store transaction in Firestore
  Future<void> storeTransaction(
      String userId, Map<String, dynamic> transaction) async {
    try {
      print("📝 Attempting to store transaction: $transaction");

      await _firestore
          .collection("users")
          .doc(userId)
          .collection("transactions")
          .add(transaction);

      print(
          "✅ Transaction stored successfully: ${transaction["transaction_id"]}");
    } catch (e) {
      print("❌ Firestore Write Error: $e");
    }
  }

  /// 📊 Get transaction stream
  Stream<QuerySnapshot> getTransactionsStream(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .snapshots();
  }
}