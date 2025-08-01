import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manymanager/domain/entities/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final Box<Transaction> _box = Hive!.box<Transaction>('transactions');

  List<Transaction> get transactions => _box.values.toList();

  void addTransaction(Transaction tx) async {
    await _box.put(tx.id, tx);
    notifyListeners();
  }

  double get balance => _box.values.fold(0.0, (sum, tx) =>
      tx.isIncome ? sum + tx.amount : sum - tx.amount);

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (var tx in _box.values) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount * (tx.isIncome ? 1 : -1);
    }
    return totals;
  }

  void deleteTransaction(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}