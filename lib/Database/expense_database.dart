import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../Modles/expense.dart';

class ExpenseDatabase extends ChangeNotifier{
  static late Isar isar;
  List<Expense> _allExpenses=[];
  /*
  S E T U P
   */

  double? _currentMonthExpense;
  double? get currentMonthExpense => _currentMonthExpense;

  //current month expense
  void setCurrentMonthExpense(double? value) {
    _currentMonthExpense = value;
    notifyListeners(); // Notify listeners when the value changes
  }

  //initialize database
  static Future<void> initialize() async{
    final dir=await getApplicationDocumentsDirectory();
    isar=await Isar.open([ExpenseSchema], directory: dir.path);
  }

  /*
  G E T T E R S
   */


  //Read from database and calculate the current month expense
  Future<void> readExpenses() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    // Calculate the current month's expense
    DateTime now = DateTime.now();
    _currentMonthExpense = _allExpenses
        .where((expense) => expense.date.month == now.month && expense.date.year == now.year)
        .fold(0.0, (sum, expense) => sum! + expense.amount);

    notifyListeners();
  }

  List<Expense> get allExpense => _allExpenses;

  /*
  O P E R A T I O N S
   */

  //Create - add a new expense
  Future<void> createNewExpense(Expense newExpense) async{
    await isar.writeTxn(() => isar.expenses.put(newExpense));
    await readExpenses();
  }

  //Read - read from database
  // Future<void> readExpenses() async {
  //   List<Expense> featchedExpensese=await isar.expenses.where().findAll();
  //   _allExpenses.clear();
  //   _allExpenses.addAll(featchedExpensese);
  //
  //   notifyListeners();
  // }

  //Update - edit expense from the database
  Future<void> updateExpense(int id, Expense updatedExpense) async{
    updatedExpense.id = id;
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    await readExpenses();
  }
  //Delete - Delete expense from the database
  Future<void> deleteExpense(int id) async{
    await isar.writeTxn(()=> isar.expenses.delete(id));
    await readExpenses();
  }
  /*
  H E L P E R
   */
  //calculate expense for each month
  Future<Map<int,double>> calculateMonthlyTotals() async {
    await readExpenses();

    //create a map to keep track of total expenses per month
    Map<int,double> monthlyTotals={
      // 0: 250
      // 1: 100
    };

    for(var expense in _allExpenses){
      int month=expense.date.month;

      if(!monthlyTotals.containsKey(month)){
        monthlyTotals[month]=0;
      }

      monthlyTotals[month] = monthlyTotals[month]!+expense.amount;
    }
    return monthlyTotals;
  }

  //getting start month
  int getStartMonth(){
    if(_allExpenses.isEmpty){
      return DateTime.now().month;
    }
    //sorting expenses by date to find the earliest
    _allExpenses.sort((a,b)=>a.date.compareTo(b.date));

    return _allExpenses.first.date.month;
  }

  //getting start year
  int getStartYear(){
    if(_allExpenses.isEmpty){
      return DateTime.now().year;
    }
    //sorting expenses by date to find the earliest
    _allExpenses.sort((a,b)=>a.date.compareTo(b.date));

    return _allExpenses.first.date.year;
  }
}