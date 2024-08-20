import 'package:chat_app_final/Helper/helper_function.dart';
import 'package:isar/isar.dart';

part 'expense.g.dart';

@Collection()
class Expense{
  Id id=Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;
  final String currMon;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
    required this.currMon,
});
}