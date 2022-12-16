import 'dart:convert';

class Transaction {
  String id;
  String title;
  double amount;
  DateTime date;

  String getJson() {
    return json.encode({
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
    });
  }

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });
}
