import 'package:hive/hive.dart';
part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  bool isIncome;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.isIncome,
  });
}
