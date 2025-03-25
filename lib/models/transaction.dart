import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String type;

  Transaction(
      {required this.amount,
      required this.category,
      required this.description,
      required this.date,
      required this.type});

  factory Transaction.fromMap(Map<String, dynamic> data) {
    return Transaction(
      amount: data['amount'],
      category: data['category'],
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'],
    );
  }
}
